/*
   PROJECT: GROUP 4 
   Script with all the commands necessary to insert data into the tables
*/


/* Load the data of the betting companies */
use Project;

/*CALL create_BettingCompanies();*/

INSERT INTO `BettingCompanies`(`CompanyName`,`CompanyCode`) VALUES
('Bet365', 'B365'),
('Blue Square', 'BS'),
('Bet&Win','BW'), 
('Gamebookers','GB'),
('Interwetten','IW'),
('Ladbrokes','LB'),
('Pinnacle','PS'),
('Sporting','SO'),
('Sportingbet','SB'),
('Stan James','SJ'),
('Stanleybet','SY'),
('VC Bet','VC'),
('William Hill','WH');


/* Load the data of the leagues and countries */

/*CALL create_Leagues();*/

INSERT INTO `Leagues` (`Country` ,`League` ) 
SELECT Country, League
FROM GeneralTable
GROUP BY Country, League;
 

/* Load the data of the teams */

/*CALL create_Teams();*/

INSERT INTO `Teams` (`TeamName`, `LeagueID`)
SELECT g.HomeTeam, l.LeagueID
FROM Leagues l join GeneralTable g
ON l.Country = g.Country
GROUP BY g.HomeTeam;

INSERT INTO `Teams` (`TeamName`, `LeagueID`)
SELECT g.AwayTeam, l.LeagueID
FROM Leagues l join GeneralTable g
ON l.Country = g.Country
WHERE g.AwayTeam NOT IN (SELECT TeamName FROM Teams)
GROUP BY g.AwayTeam;


/* Load the data of the match */

-- select * from generaltable where Date ='23/02/2002';

/*CALL create_Matches();*/

INSERT INTO `Matches` ( `MatchID`, `MatchDate`,`Season`, `Referee`, `HomeTeamID`, `AwayTeamID`, `LeagueId`,`Result`) 
SELECT  g.MatchID, str_to_date(g.Date, '%d/%m/%Y'), g.Year, g.Referee, th.TeamID , ta.TeamID, l.leagueID , g.FTR 
FROM GeneralTable AS g
	LEFT JOIN Teams AS th
		ON g.HomeTeam = th.TeamName
	LEFT JOIN Teams AS ta
		ON g.AwayTeam = ta.TeamName
	LEFT JOIN Leagues AS l
		ON l.Country = g.Country
ORDER BY g.MatchID desc;
    SELECT MatchID , Date FROM GeneralTable;
    SELECT MatchID , MatchDate FROM Matches;

/* Load the data of each betting company for each match */

/*CALL create_Bets();*/

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'B365', B365H, B365A, B365D, bet_prediction_success(B365H, B365A, B365D, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'BW', BWH, BWA, BWD, bet_prediction_success(BWH, BWA, BWD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'BS', BSH, BSA, BSD, bet_prediction_success(BSH, BSA, BSD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'IW', IWH, IWA, IWD, bet_prediction_success (IWH, IWA, IWD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'LB', LBH, LBA, LBD, bet_prediction_success (LBH, LBA, LBD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'SJ', SJH, SJA, SJD, bet_prediction_success (SJH, SJA, SJD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'PS', PSH, PSA, PSD, bet_prediction_success (PSH, PSA, PSD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'WH', WHH, WHA, WHD, bet_prediction_success (WHH, WHA, WHD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'VC', VCH, VCA, VCD, bet_prediction_success (VCH, VCA, VCD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'SO', SOH, SOA, SOD, bet_prediction_success (SOH, SOA, SOD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'GB', GBH, GBA, GBD, bet_prediction_success (GBH, GBA, GBD, FTR)
FROM GeneralTable;

INSERT INTO `Bets` (`MatchID`, `CompanyCode`, `HomeWinOdds`, `AwayWinOdds`, `DrawOdds`, `PredictionSuccess`)
SELECT MatchID, 'SB', SBH, SBA, SBD, bet_prediction_success (SBH, SBA, SBD, FTR)
FROM GeneralTable;


/* Load the data of the match statistics for the home team and for the away team */


/*CALL create_MatchStat();*/

INSERT INTO `MatchStat`(`MatchID`,`TeamID`, `FullTimeGoals`, `LeaguePoints`, `HomeAway`, `HalfTimeGoals`, `HalfTimeResult`, `Shots`, `ShotsOnTarget`, `Corners`, `FoulsCommitted`, `YellowCards`, `RedCards`)
SELECT g.MatchID, t.TeamID, g.FTHG, result_to_points(g.FTR, 'H'), 'H', g.HTHG, g.HTR, g.HS, g.HST, g.HC, g.HF,  g.HY, g.HR 
FROM GeneralTable AS g, Teams AS t
WHERE g.HomeTeam = t.TeamName;

INSERT INTO `MatchStat`(`MatchID`,`TeamId`, `FullTimeGoals`,`LeaguePoints`, `HomeAway`, `HalfTimeGoals`, `HalfTimeResult`, `Shots`, `ShotsOnTarget`, `Corners`, `FoulsCommitted`, `YellowCards`, `RedCards`)
SELECT g.MatchID, t.TeamID, g.FTAG, result_to_points(FTR, 'A'), 'A', g.HTAG, g.HTR, g.`AS`, g.AST, g.AC, g.AF,  g.AY, g.AR
FROM GeneralTable AS g, Teams AS t
WHERE g.AwayTeam = t.TeamName;

/* Calling a view that is used in some functions to create tables */
CALL create_countview();

/* Compute the winners of each league and year */

CALL create_winners;

drop table if exists GeneralTable ;

