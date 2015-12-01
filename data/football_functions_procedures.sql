/*
   PROJECT: GROUP 4 
   Script with all the functions and procedures needed to create the database
*/

use Project;

/* MATCH STATISTICS: compute the column points*/
DROP FUNCTION IF EXISTS result_to_points;
DELIMITER //
CREATE FUNCTION result_to_points(result varchar(1), ha varchar(1)) 
RETURNS int
BEGIN
    declare points int;
    if result = ha then set points = 3;
    elseif result = 'D' then set points = 1;
    else set points = 0;
    end if;
    RETURN points;
END //
DELIMITER ;


/* Aggregate Score from each match */
DROP FUNCTION IF EXISTS agg_score;
DELIMITER //
CREATE FUNCTION agg_score (T_ID int, M_ID int)
RETURNS int
BEGIN

	declare GD int;
    
    set GD = (SELECT FullTimeGoals FROM MatchStat WHERE MatchID = M_ID AND TeamID = T_ID ) 
		   - (SELECT FullTimeGoals FROM MatchStat WHERE MatchID = M_ID AND TeamID != T_ID);
	
    RETURN GD;

END //
DELIMITER ;


/* BETTING COMPANIES: compute the column prediction_success */
DROP FUNCTION IF EXISTS bet_prediction_success;
DELIMITER //
CREATE FUNCTION bet_prediction_success (hw double, aw double, dw double, result varchar(1)) 
RETURNS bool
BEGIN
    declare success bool;
    declare win varchar (1);
    declare minimum double;
    set minimum = least(hw, aw, dw);
    
    if minimum = hw then set win = 'H';
    elseif minimum = aw then set win = 'A';
    elseif minimum = dw then set win = 'D';
    end if;
    
    if win = result then set success = 1;
    else set success = 0;
    end if;
    
    if hw IS NULL then set success = NULL;
    elseif aw IS NULL then set success = NULL;
    elseif dw IS NULL then set success = NULL;
    end if;
    
    RETURN success;
END //
DELIMITER ;


/* Winners: compute the table winners*/
/*
DROP PROCEDURE IF EXISTS create_winners;
DELIMITER //    
CREATE PROCEDURE create_winners()
BEGIN

DROP TABLE IF EXISTS Winners;

CREATE TABLE Winners (
LeagueID int(11) not null,
Season int(4) not null,
TeamID int(11) not null,
Points int(5) not null,

primary key (LeagueID, Season),
foreign key (LeagueID) references Leagues (LeagueID),
foreign key (TeamID) references Teams (TeamID)
);

DROP VIEW IF EXISTS temp1;
DROP VIEW IF EXISTS temp2;

CREATE VIEW temp1 AS 
SELECT m.LeagueID, m.Season, ms.TeamID , sum(ms.LeaguePoints) AS FinalPoints
FROM MatchStat AS ms, Matches AS m
WHERE ms.MatchID = m.MatchID  
GROUP BY m.LeagueId, m.Season, ms.TeamID;
  
CREATE VIEW temp2 AS 
SELECT LeagueID, Season, max(FinalPoints) AS maxFinPoints
FROM temp1
GROUP BY LeagueId, Season;


INSERT INTO `Winners`(`LeagueID`, `Season`, `TeamID`, `Points`)
SELECT temp1.LeagueID, temp1.Season, temp1.TeamID, temp1.FinalPoints
FROM temp1 INNER JOIN temp2
ON temp1.LeagueID = temp2.LeagueID AND temp1.Season = temp2.Season AND temp1.FinalPoints = temp2.MaxFinPoints;


DROP VIEW IF EXISTS temp1;
DROP VIEW IF EXISTS temp2;

END //
DELIMITER ;
*/




/*DROP PROCEDURE IF EXISTS create_BettingCompanies;
DELIMITER //
CREATE PROCEDURE create_BettingCompanies()
BEGIN

DROP TABLE IF EXISTS BettingCompanies;

CREATE TABLE BettingCompanies (
    CompanyCode VARCHAR(11),
    CompanyName VARCHAR(25),

    primary key (CompanyCode)

);
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS create_Leagues;
DELIMITER //
CREATE PROCEDURE create_Leagues()

BEGIN

DROP TABLE IF EXISTS Leagues;

CREATE TABLE Leagues (
    LeagueID INT(11) AUTO_INCREMENT,
    Country VARCHAR(20),
    League VARCHAR(20),

    primary key (LeagueID)
);
END //
DELIMITER ; 



DROP PROCEDURE IF EXISTS create_Teams;
DELIMITER //
CREATE PROCEDURE create_Teams()
BEGIN

DROP TABLE IF EXISTS Teams;

CREATE TABLE Teams (
    TeamID INT(11) AUTO_INCREMENT,
    TeamName VARCHAR(25),
	LeagueID INT(11),

    primary key (TeamID),
    foreign key (LeagueID) references Leagues (LeagueID)
);
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS create_Matches;
DELIMITER //
CREATE PROCEDURE create_Matches()
BEGIN

DROP TABLE IF EXISTS Matches;

CREATE TABLE Matches (
    MatchID INT(11),
    MatchDate DATE,
    Season INT(2),
    Referee VARCHAR(20),
    HomeTeamID INT(11),
    AwayTeamID INT(11),
    LeagueID INT(11),
    Result VARCHAR(1),

    primary key (MatchID),
    foreign key (HomeTeamID) references Teams (TeamID),
    foreign key (AwayTeamID) references Teams (TeamID),
    foreign key (LeagueID) references Leagues (LeagueID)
);
END //
DELIMITER ;




DROP PROCEDURE IF EXISTS create_Bets;
DELIMITER //
CREATE PROCEDURE create_Bets()
BEGIN

DROP TABLE IF EXISTS Bets;

CREATE TABLE Bets (
    MatchID INT(11),
    CompanyCode VARCHAR(4),
    HomeWinOdds DOUBLE,
    AwayWinOdds DOUBLE,
    DrawOdds DOUBLE,
    PredictionSuccess INT(1),

    primary key (MatchID, CompanyCode),
    foreign key (MatchID) references Matches (MatchID),
    foreign key (CompanyCode) references BettingCompanies (CompanyCode)
);
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS create_MatchStat;
DELIMITER //
CREATE PROCEDURE create_MatchStat()
BEGIN

DROP TABLE IF EXISTS MatchStat;

CREATE TABLE MatchStat (
    MatchID INT(11),
    TeamID INT(11),
    FullTimeGoals INT(2),
    LeaguePoints INT(1),
    HomeAway VARCHAR(1),
    HalfTimeGoals INT(2),
    HalfTimeResult VARCHAR(1),
    Shots INT(2),
    ShotsOnTarget INT(2),
    Corners INT(2),
    FoulsCommitted INT(2),
    YellowCards INT(2),
    RedCards INT(2),

    primary key (MatchID, TeamID),
    foreign key (TeamID) references Teams (TeamID),
    foreign key (MatchID) references Matches (MatchID)

);

END //
DELIMITER ;


*/ 

-- MAIN problem now is that it is not doing over the desired dates - only picking one match
-- I think should try to implement as in exercise
DROP PROCEDURE IF EXISTS create_countview;
DELIMITER //
CREATE PROCEDURE create_countview()
BEGIN

DROP VIEW IF EXISTS countview;
CREATE VIEW countview AS
SELECT t.TeamID,
	   m.LeagueID,
       m.MatchDate,
       m.Season,
       
	   sum(CASE WHEN ms.LeaguePoints = 3 then 1 else 0 end) AS games_won,
       sum(CASE WHEN ms.LeaguePoints = 1 then 1 else 0 end) AS games_drawn,
       sum(CASE WHEN ms.LeaguePoints = 0 then 1 else 0 end) AS games_lost,
       count(m.MatchID) AS games_played,
       agg_score(t.TeamID, ms.MatchID) AS goal_diff
FROM Teams t join MatchStat ms
ON t.TeamID = ms.TeamID
JOIN Matches m
ON m.MatchID = ms.MatchID
GROUP BY t.TeamID, m.MatchDate;

END //
DELIMITER ;



DROP PROCEDURE IF EXISTS create_winners;
DELIMITER //    
CREATE PROCEDURE create_winners()
BEGIN

DROP TABLE IF EXISTS Winners;

CREATE TABLE Winners (
LeagueID int(11) not null,
Season int(4) not null,
TeamID int(11) not null,
Points int(5) not null,

primary key (LeagueID, Season),
foreign key (LeagueID) references Leagues (LeagueID),
foreign key (TeamID) references Teams (TeamID)
);

DROP VIEW IF EXISTS temp1;
DROP VIEW IF EXISTS temp2;

CREATE VIEW temp1 AS 
SELECT LeagueID, Season, TeamID , sum(games_won)*3 + sum(games_drawn) AS FinalPoints, 
	   sum(goal_diff) AS goal_difference, sum(goal_diff)/1000 AS bonus
FROM countview 
GROUP BY Season, TeamID;
  
CREATE VIEW temp2 AS 
SELECT LeagueID, Season, max(FinalPoints + bonus) AS maxFinPoints
FROM temp1
GROUP BY LeagueId, Season;

INSERT INTO `Winners`(`LeagueID`, `Season`, `TeamID`, `Points`)
SELECT temp1.LeagueID, temp1.Season, temp1.TeamID, temp1.FinalPoints
FROM temp1 join temp2 ON temp1.LeagueID = temp2.LeagueID AND  temp1.Season = temp2.Season
WHERE (temp1.FinalPoints + temp1.bonus) = temp2.maxFinPoints;

DROP VIEW IF EXISTS temp1;
DROP VIEW IF EXISTS temp2;

END //
DELIMITER ;



/* CALL create_evolution('2003-08-16' , '2004-05-15');
select * from TableEvolution;*/

DROP PROCEDURE IF EXISTS create_evolution;
DELIMITER //    
CREATE PROCEDURE create_evolution(dt_ini DATE, dt_end DATE)
BEGIN


DROP TABLE IF EXISTS TableEvolution;
CREATE table TableEvolution (
    LeagueID int(11) not null,
    dt_ini date,
    dt_end date,
    TeamID int(11) not null,
    Games_played int(2),
    Games_won int(2),
    Games_lost int(2),
    Games_drawn int(2),
    Goal_difference int(4),
    Total_points int(3)
);

INSERT INTO TableEvolution (LeagueID, dt_ini, dt_end,
            TeamID, Games_played, Games_won, 
            Games_lost, Games_drawn, Goal_difference, Total_points)
SELECT t.LeagueID, dt_ini, dt_end, cv.TeamID, sum(cv.games_played),
       sum(cv.games_won), sum(cv.games_lost), sum(cv.games_drawn), sum(cv.goal_diff),
       (sum(cv.games_won)*3 + sum(cv.games_drawn)) AS total_points
FROM Teams t join countview cv ON t.TeamID = cv.TeamID
WHERE cv.MatchDate between dt_ini and dt_end
GROUP BY cv.TeamID
ORDER BY t.LeagueID, total_points desc;

END //
DELIMITER ;


DROP FUNCTION IF EXISTS win_odd;
DELIMITER //
CREATE FUNCTION win_odd(MId double, result varchar(1), code VARCHAR(4) ) 
RETURNS int
BEGIN
    declare odd double;
    
    if result = 'H' then set odd = (SELECT b.HomeWinOdds FROM Project.Bets AS b WHERE b.MatchId = MId AND b.CompanyCode = code);
    elseif result = 'A' then set odd = (SELECT b.AwayWinOdds FROM Project.Bets AS b WHERE b.MatchId = MId AND b.CompanyCode = code);
    elseif result = 'D' then set odd = (SELECT b.DrawOdds FROM Project.Bets AS b WHERE b.MatchId = MId AND b.CompanyCode = code);
    end if;

    RETURN odd;
END //
DELIMITER ;
