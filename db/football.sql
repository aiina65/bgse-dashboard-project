drop database if exists Project;
create database  Project;
use Project;



CREATE TABLE Leagues (
    LeagueID INT(11) AUTO_INCREMENT,
    Country VARCHAR(20),
    League VARCHAR(20),

    primary key (LeagueID)
);


CREATE TABLE Teams (
    TeamID INT(11) AUTO_INCREMENT,
    TeamName VARCHAR(25),
	LeagueID INT(11),

    primary key (TeamID),
    foreign key (LeagueID) references Leagues (LeagueID)
);


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




create table BettingCompanies (
	CompanyCode varchar(7),
	CompanyName varchar(25),
    
primary key (CompanyCode)
);



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

/*create table ClassEvolution (
	MatchID int(11) not null,
	TeamID int(11) not null,
	Season int(4) not null,
	LeagueID int(11) not null,
	LastPosition int(5),
	ActualPosition int(5),
	GoalDifference int(5),
	GameWeek int(5),
    
primary key (MatchID, TeamID, Season),
foreign key (MatchID) references Matches (MatchID),
foreign key (TeamID) references Teams (TeamID)
);*/



CREATE TABLE Winners (
LeagueID int(11) not null,
Season int(4) not null,
TeamID int(11) not null,
Points int(5) not null,

primary key (LeagueID, Season),
foreign key (LeagueID) references Leagues (LeagueID),
foreign key (TeamID) references Teams (TeamID)
);


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

CREATE INDEX Team ON Project.MatchStat (TeamID);
CREATE INDEX Bet ON Project.Bets (CompanyCode);