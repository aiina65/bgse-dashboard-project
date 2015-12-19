library(RMySQL)
library(igraph)
library(betareg)

## Connection to SQL
db = dbConnect(MySQL(), user='root', password='root' , dbname='Project', host='localhost')

## Import data
result    <- dbSendQuery(db, "SELECT b.CompanyCode, t.TeamName, avg(b.PredictionSuccess), avg(b.PredictionSuccess)*count(*) as Score
                              FROM Project.Bets AS b, Project.MatchStat AS ms, Project.Teams As t
                              WHERE b.MatchId = ms.MatchId AND ms.TeamId = t.TeamId AND b.PredictionSuccess IS NOT NULL 
                              GROUP BY b.CompanyCode, ms.TeamId;")

relations <- fetch(result, n=-1)
# relations <- relations[relations$Matches >= mean(relations$Matches),]
relations <- data.frame(from = relations$CompanyCode, to = relations$TeamName, weight = relations$Score)

## Analysis: maximum matching bipartite graph                      
g <- graph.data.frame(relations, directed=FALSE)

V(g)$type               <- TRUE
V(g)$type[13:vcount(g)] <- rep(FALSE, (vcount(g)-12))

m   <- max_bipartite_match(g, types = NULL, weights = NULL, eps = .Machine$double.eps)
num <- as.double(m[1])
matches <- as.data.frame(m[3], stringsAsFactors = FALSE)
maxmatching <- data.frame( "Betting Company" = rownames(matches)[1:num], "Team" = matches[1:num,])


dbSendQuery(db,"drop table if exists Matching")
dbWriteTable(conn = db,name="Matching", value=maxmatching, row.names=FALSE)




#########################################
############# SECOND OPTION ############# 
#########################################
db = dbConnect(MySQL(), user='root', password='root' , dbname='Project', host='localhost')

## Import data
result_risk    <- dbSendQuery(db, "SELECT b.CompanyCode, t.TeamName, avg(b.PredictionSuccess), avg(b.PredictionSuccess)*count(*)*avg(win_odd(m.MatchId, m.Result, b.CompanyCode)) as Score
                                    FROM Project.Bets AS b, Project.MatchStat AS ms, Project.Teams As t, Matches AS m
                                    WHERE b.MatchId = ms.MatchId AND m.MatchId = ms.MatchId AND ms.TeamId = t.TeamId AND b.PredictionSuccess IS NOT NULL  
                                    GROUP BY b.CompanyCode, ms.TeamId;")

relations_risk <- fetch(result_risk, n=-1)
# relations <- relations[relations$Matches >= mean(relations$Matches),]
relations_risk <- data.frame(from = relations_risk$CompanyCode, to = relations_risk$TeamName, weight = relations_risk$Score)

## Analysis: maximum matching bipartite graph                      
g_risk <- graph.data.frame(relations_risk, directed=FALSE)

V(g_risk)$type               <- TRUE
V(g_risk)$type[13:vcount(g_risk)] <- rep(FALSE, (vcount(g_risk)-12))

m_risk   <- max_bipartite_match(g_risk, types = NULL, weights = NULL, eps = .Machine$double.eps)
num_risk <- as.double(m_risk[1])
matches_risk <- as.data.frame(m_risk[3], stringsAsFactors = FALSE)
maxmatching_risk <- data.frame( "Betting Company" = rownames(matches_risk)[1:num_risk], "Team" = matches_risk[1:num_risk,])


dbSendQuery(db,"drop table if exists MatchingRisk")
dbWriteTable(conn = db,name="MatchingRisk", value=maxmatching_risk, row.names=FALSE)

sub.select <- function(c, nmatches, nteams){
  if(c == 1){
    subs <- 1:(nrow(z) - nmatches*nteams)
  } else{
    c(1:(nrow(z) - c*nmatches*nteams),(nrow(z)-(c - 1)*nmatches*nteams):nrow(z))
  }
}



#Connection to SQL
db = dbConnect(MySQL(), user='root', password='root' , dbname='Project', host='localhost')

# Import data 
result = dbSendQuery(db,"SELECT m.Season, l.League, m.MatchDate,
                     t.TeamName AS Team, top.Teamname AS Opposition,
                     ms.HomeAway, m.Referee, m.Result, ms.LeaguePoints,
                     ms.FullTimeGoals AS Goals, 
                     mso.FullTimeGoals AS GoalsConceded,
                     b.HomeWinOdds, b.AwayWinOdds, b.DrawOdds, b.PredictionSuccess
                     FROM Leagues l JOIN Teams t ON l.LeagueID = t.LeagueID
                     JOIN MatchStat ms ON t.TeamID = ms.TeamID
                     JOIN MatchStat mso ON mso.MatchID = ms.MatchID AND t.TeamID != mso.TeamID
                     JOIN Teams top ON top.TeamID = mso.TeamID
                     JOIN Matches m ON ms.MatchID = m.MatchID AND m.Season > 2001
                     JOIN Bets b ON b.MatchID = ms.MatchID AND CompanyCode = \"B365\" 
                     WHERE l.League = \"SP\"
                     ORDER BY m.Season, t.TeamName, m.MatchDate")

match.data = fetch(result, n=-1)

# Building a function to clean the data in the way that I want for the regression
data.cleanup <- function(match.data, nmatches, nteams){
  # Defining home and away variables
  match.data$HomeAway <- ifelse(match.data$HomeAway == "H", 1, 0)
  
  # Win vs loss or draw variables
  
  match.data$Result[(match.data$Result == "H" & match.data$HomeAway == 1) |
                      (match.data$Result == "A" & match.data$HomeAway == 0)] <- 2
  
  match.data$Result[(match.data$Result == "H" & match.data$HomeAway != 1) |
                      (match.data$Result == "A" & match.data$HomeAway != 0)] <- 0
  match.data$Result[match.data$Result == "D"] <- 1
  
  match.data$Result <- as.numeric(match.data$Result)
  
  
  # Odds for winning vs. drawing vs. losing
  match.data$WinOdds <- ifelse(match.data$HomeAway == 1, match.data$HomeWinOdds,
                               match.data$AwayWinOdds)
  match.data$LoseOdds <- ifelse(match.data$HomeAway == 1, match.data$AwayWinOdds,
                                match.data$HomeWinOdds)
  
  # Getting league position BEFORE each match - and the position in the table before each match
  Seasons <- unique(match.data$Season)

  TotalPoints <- rep(0,nrow(match.data))
  for(i in 1:nrow(match.data)){
    if((i-1) %% nmatches == 0){
      TotalPoints[i] <- 0
      Tstart <- i
    } else {
      TotalPoints[i] <- sum(match.data$LeaguePoints[Tstart:(i-1)])
    }
  }
  match.data$PointsBefore <- TotalPoints
  
  match.data$PositionBefore <- rep(0,nrow(match.data))
  
  for(j in 1:length(Seasons)){
    for(i in 1:nmatches){
      match.data$PositionBefore[c((nmatches*nteams*(j-1)+i)+(0:(nteams-1))*nmatches)] <- 
        rank(-(match.data$PointsBefore[c((nmatches*nteams*(j-1)+i)+(0:(nteams-1))*nmatches)]),
             ties.method = "min")
    }
  }
  
  # Creating positions "last season". For this, should need to input 
  match.data$PrevSeas <- rep(0,nrow(match.data))
  
  for(j in 1:(length(Seasons)-1)){
    a <- rank(-(match.data$PointsBefore[c((nmatches*nteams*(j-1)+nmatches)+(0:(nteams-1))*nmatches)] + 
                  match.data$LeaguePoints[c((nmatches*nteams*(j-1)+nmatches)+(0:(nteams-1))*nmatches)]),
              ties.method = "min")
    prevteams <- unique(match.data$Team[match.data$Season == Seasons[j]])
    
    for(i in 1:(nteams-1)){
      if(j != 99){
        match.data$PrevSeas[match.data$Team == prevteams[i] & match.data$Season == Seasons[(j+1)]] <- a[i]
      }
    }
  }
  
  # Adding data of opposition team
  OPTeam <- match.data$Opposition
  Date <- match.data$MatchDate
  
  match.data$OP.PositionBefore <- rep(0,nrow(match.data))
  match.data$OP.PrevSeas <- rep(0,nrow(match.data))
  
  for(i in 1:length(OPTeam)){
    match.data$OP.PositionBefore[i] <- match.data$PositionBefore[match.data$Team == OPTeam[i] &
                                                                   match.data$MatchDate == Date[i]]
    match.data$OP.PrevSeas[i] <- match.data$PrevSeas[match.data$Team == OPTeam[i] &
                                                       match.data$MatchDate == Date[i]]
  }
  
  # Adding goals for and coals conceded
  start <- seq(1,nrow(match.data),nmatches)
  
  match.data$GoalsFor <- as.numeric(sapply(start,function(i) {
    sapply(seq(i,(i+nmatches - 1)), function(j) {
      sum(match.data$Goals[i:j])
    })
  }))
  
  match.data$GoalsAgainst <- as.numeric(sapply(start,function(i) {
    sapply(seq(i,(i+nmatches - 1)), function(j) {
      sum(match.data$GoalsConceded[i:j])
    })
  }))
  
  match.data$GoalDifference <- match.data$GoalsFor - match.data$GoalsAgainst
  
  match.data$GFS <- (match.data$GoalsFor)^2
  match.data$GAS <- (match.data$GoalsAgainst)^2
  match.data$GDS <- (match.data$GoalDifference)^2
  
  # Developing classification of team positions -> should be changed for different leagues
  top3 <- c(1,2,3)
  top6 <- c(4,5,6,7)
  midtable <- c(8:12)
  lowtable <- c(13:16)
  relegation <- c(17:20)
  
  match.data$ClassBefore[match.data$PositionBefore %in% top3] <- "Top3"
  match.data$ClassBefore[match.data$PositionBefore %in% top6] <- "Top6"
  match.data$ClassBefore[match.data$PositionBefore %in% midtable] <- "MidTable"
  match.data$ClassBefore[match.data$PositionBefore %in% lowtable] <- "MidTable"
  match.data$ClassBefore[match.data$PositionBefore %in% relegation] <- "MidTable"
  
  match.data$PrevClass[match.data$PrevSeas %in% top3] <- "Top3"
  match.data$PrevClass[match.data$PrevSeas %in% top6] <- "Top6"
  match.data$PrevClass[match.data$PrevSeas %in% midtable] <- "MidTable"
  match.data$PrevClass[match.data$PrevSeas %in% c(13:17)] <- "MidTable"
  match.data$PrevClass[match.data$PrevSeas == 0] <- "Promoted"
  
  # And opposition teams
  match.data$OP.ClassBefore[match.data$OP.PositionBefore %in% top3] <- "Top3"
  match.data$OP.ClassBefore[match.data$OP.PositionBefore %in% top6] <- "Top6"
  match.data$OP.ClassBefore[match.data$OP.PositionBefore %in% midtable] <- "MidTable"
  match.data$OP.ClassBefore[match.data$OP.PositionBefore %in% lowtable] <- "MidTable"
  match.data$OP.ClassBefore[match.data$OP.PositionBefore %in% relegation] <- "MidTable"
  
  match.data$OP.PrevClass[match.data$OP.PrevSeas %in% top3] <- "Top3"
  match.data$OP.PrevClass[match.data$OP.PrevSeas %in% top6] <- "Top6"
  match.data$OP.PrevClass[match.data$OP.PrevSeas %in% midtable] <- "MidTable"
  match.data$OP.PrevClass[match.data$OP.PrevSeas %in% c(13:17)] <- "MidTable"
  match.data$OP.PrevClass[match.data$OP.PrevSeas == 0] <- "Promoted"
  
  return(match.data)
}

n <- 38
nt <- length(unique(match.data$Team[match.data$Season == 2003]))

match.data <- data.cleanup(match.data, n, nt)

### Sample Creation ###
z <- match.data[c(1,4,16,17,14,15,8,6,7,23:32)]
z <- z[!is.na(z$WinOdds),]

z$GLMwin <- ifelse(z$Result == 2,1,0)
z$GLMlose <- ifelse(z$Result == 0,1,0)
z$GLMdraw <- ifelse(z$Result == 1,1,0)

z$ClassBefore <- factor(z$ClassBefore, levels = c("MidTable","Top6","Top3"), ordered = T)
z$PrevClass <- factor(z$PrevClass, levels = c("Promoted","MidTable","Top6","Top3"), ordered = T)
z$OP.ClassBefore <- factor(z$OP.ClassBefore, levels = c("MidTable","Top6","Top3"), ordered = T)
z$OP.PrevClass <- factor(z$OP.PrevClass, levels = c("Promoted","MidTable","Top6","Top3"), ordered = T)

subs <- sub.select(4,n, nt)

train <- z[subs,]
test <- z[-subs,]

### Odd regressions ### 
# Transforming to pseudo probabilities
train$WinOdds <- 1/train$WinOdds
train$LoseOdds <- 1/train$LoseOdds
train$DrawOdds <- 1/train$DrawOdds

test$WinOdds <- 1/test$WinOdds
test$LoseOdds <- 1/test$LoseOdds
test$DrawOdds <- 1/test$DrawOdds

# With a linear model
lin.mod.w <- lm(WinOdds ~ HomeAway  + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass,data=train)
lin.mod.l <- lm(LoseOdds ~ HomeAway  + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass,data=train)
lin.mod.d <- lm(DrawOdds ~ HomeAway  + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass,data=train)

# Beta model
beta.mod.w <- betareg(WinOdds ~ HomeAway + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass,data=train)
beta.mod.l <- betareg(LoseOdds ~ HomeAway + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass,data=train)
beta.mod.d <- betareg(DrawOdds ~ HomeAway + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass,data=train)

# Predicting based on test set
lin.pred.w <- predict(lin.mod.w,test, type="response")
lin.pred.l <- predict(lin.mod.l,test, type="response")
lin.pred.d <- predict(lin.mod.d,test, type="response")

beta.pred.w <- predict(beta.mod.w,test, type="response")
beta.pred.l <- predict(beta.mod.l,test, type="response")
beta.pred.d <- predict(beta.mod.d,test, type="response")

### Match prediction ###
mod.win <-  glm(GLMwin ~ HomeAway  + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass
                 + GoalsFor + GoalsAgainst + GFS + GAS,
                 family = binomial(),data = train)
mod.lose <- glm(GLMlose ~ HomeAway  + ClassBefore + OP.ClassBefore + PrevClass + OP.PrevClass
                 + GoalsFor + GoalsAgainst + GFS + GAS,
                 family = binomial(),data = train)

train$WinMod <- predict(mod.win, train, type = "response")
train$LoseMod <- predict(mod.lose, train, type = "response")
test$WinMod <- predict(mod.win, test, type = "response")
test$LoseMod <- predict(mod.lose, test, type = "response")

mod.draw <- glm(GLMdraw ~ WinMod + LoseMod, family = binomial(), data = train)

# Predicting test set
pred.win <- predict(mod.win, test, type = "response")
pred.lose <- predict(mod.lose, test, type = "response")

pred.draw <- predict(mod.draw, test, type = "response")

# Thresholding the different values to determine which result we have
win.predict <- ifelse(pred.win > 0.35,1,0)

lose.predict <- ifelse(pred.lose > 0.3,1,0)

# For draws, want to use a threshold to determine probability for a draw as well
draw.predict <- ifelse(win.predict == lose.predict,
                          ifelse(pred.draw > 0.28,1,0),
                          0)

win.predict <- ifelse(win.predict == lose.predict & 
                      lose.predict == draw.predict &
                      pred.win > pred.lose,
                          win.predict + 1,
                          win.predict + 0)

lose.predict <- ifelse(win.predict == lose.predict & 
                       lose.predict == draw.predict &
                       pred.win < pred.lose,
                          lose.predict + 1,
                          lose.predict + 0)

# Getting the successes - can be removed, was kept even though redundant just to evaluate shortcomings better
win.pred.succ <- ifelse(win.predict == test$GLMwin,1,0)
lose.pred.succ <- ifelse(lose.predict == test$GLMlose,1,0)
draw.pred.succ <- ifelse(draw.predict == test$GLMdraw,1,0)

# Putting the actual predicted result into a single column
predicted.result <- ifelse(win.predict == 1,2,ifelse(draw.predict == 1,1,0))
predicted.succ <- ifelse(predicted.result == test$Result,1,0)

# Plotting the coefficients
beta.win <- coef(beta.mod.w)
beta.lose <- coef(beta.mod.l)
beta.draw <- coef(beta.mod.d)
pred.win <- coef(mod.win)
pred.lose <- coef(mod.lose)
pred.draw <- coef(mod.draw)

jpeg("betcoeffgraph.jpg", width = 650)
plot(beta.win,col="green",xaxt="n", xlab="Coefficients", ylab="value", ylim=c(-1.5,1.5),
     main = "Beta Regression Betting Odds")
points(beta.lose,col="red")
points(beta.draw,col="blue")
axis(1,at=1:13,labels = names(beta.win),cex.axis=0.6)
dev.off()

jpeg("predcoeffgraph.jpg", width = 650)
plot(pred.win,col="green",xaxt="n", xlab="Coefficients", ylab="value", ylim=c(-1.5,1.5),
     main = "Match Prediction GLM")
points(pred.lose,col="red")
axis(1,at=1:16,labels = names(pred.win),cex.axis=0.6)
dev.off()

