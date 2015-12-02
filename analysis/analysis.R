library(RMySQL)
library(igraph)

## Connection to SQL
db = dbConnect(MySQL(), user='root', password='' , dbname='Project', host='localhost')

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
db = dbConnect(MySQL(), user='root', password='' , dbname='Project', host='localhost')

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
dbWriteTable(conn = db,name="MatchingRisk", value=maxmatching, row.names=FALSE)

