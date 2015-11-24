<?php

	include 'functions.php';
	$GLOBALS['graphid'] = 0;

	// Load libraries
	document_header();

	// Create connection
	$link = connect_to_db();
?>
	<div id="data" style="display: none">
	
	<h2>Data</h2>
	
	<p>Blablabla</p>
	
	<p> The chart below shows the 10 best teams of the history.</p>

<?php
    // Teams, winned games
    
    $query = "SELECT t.TeamName, avg(m.LeaguePoints)
              FROM Project.MatchStat AS m, Project.Teams AS t 
              WHERE m.TeamID = t.TeamID
              GROUP BY m.teamID ORDER BY avg(m.LeaguePoints) DESC LIMIT 10";
    $title = "Top Best Teams";
    query_and_print_graph($query,$title,"Average League Points");
?>

	
	<p>The chart below shows the results of a similar analysis, this time the 10 worst teams of the history.</p>
	
<?php
	// Page body. Write here your queries
	
	$query = "SELECT t.TeamName, avg(m.LeaguePoints)
                  FROM Project.MatchStat AS m, Project.Teams AS t 
                  WHERE m.TeamID = t.TeamID 
                  GROUP BY m.teamID ORDER BY avg(m.LeaguePoints) ASC LIMIT 10";
        $title = "Top Worst Teams";
	query_and_print_graph($query,$title,"Average League Points");
?>


	<p>Blablabla.</p>
	
<?php
	// Page body. Write here your queries
	
	$query = "DROP VIEW IF EXISTS temp;
                  CREATE VIEW temp AS 
                  SELECT avg(ms.FullTimeGoals) AS FullTimeGoals, avg(ms.LeaguePoints) AS LeaguePoints, avg(ms.HalfTimeGoals) AS HalfTimeGoals, avg(ms.Shots) AS Shots, avg(ms.ShotsOnTarget) AS ShotsOnTarget , avg(ms.FoulsCommitted) AS Fouls, avg(ms.YellowCards) AS YellowCards, avg(ms.RedCards) AS RedCards
                  FROM Project.MatchStat AS ms
                  WHERE ms.HomeAway = 'H';

                  SELECT FullTimeGoals value, 'FullTimeGoals' descrip
                  from temp
                  union all
                  select LeaguePoints value, 'LeaguePoints' descrip
                  from temp
                  union all
                  select HalfTimeGoals value, 'HalfTimeGoals' descrip
                  from temp
                  union all
                  select Shots value, 'Shots' descrip
                  from temp
                  union all
                  select ShotsOnTarget value, 'ShotsOnTarget' descrip
                  from temp
                  union all
                  select Fouls value, 'Fouls' descrip
                  from temp
                  union all
                  select YellowCards value, 'YellowCards' descrip
                  from temp
                  union all
                  select RedCards value, 'RedCards' descrip
                  from temp";

        $query2 = "DROP VIEW IF EXISTS temp2;
                  CREATE VIEW temp2 AS 
                  SELECT avg(ms.FullTimeGoals) AS FullTimeGoals, avg(ms.LeaguePoints) AS LeaguePoints, avg(ms.HalfTimeGoals) AS HalfTimeGoals, avg(ms.Shots) AS Shots, avg(ms.ShotsOnTarget) AS ShotsOnTarget , avg(ms.FoulsCommitted) AS Fouls, avg(ms.YellowCards) AS YellowCards, avg(ms.RedCards) AS RedCards
                  FROM Project.MatchStat AS ms
                  WHERE ms.HomeAway = 'A';

                  SELECT FullTimeGoals value, 'FullTimeGoals' descrip
                  from temp2
                  union all
                  select LeaguePoints value, 'LeaguePoints' descrip
                  from temp2
                  union all
                  select HalfTimeGoals value, 'HalfTimeGoals' descrip
                  from temp2
                  union all
                  select Shots value, 'Shots' descrip
                  from temp2
                  union all
                  select ShotsOnTarget value, 'ShotsOnTarget' descrip
                  from temp2
                  union all
                  select Fouls value, 'Fouls' descrip
                  from temp2
                  union all
                  select YellowCards value, 'YellowCards' descrip
                  from temp2
                  union all
                  select RedCards value, 'RedCards' descrip
                  from temp2";
        $title = "Top Teams";
       query_and_print_multiple_graph($query,$query2,$title,"Average Number of Units");
?>


	<p>Blablabla.</p>



<?php
	// Page body. Write here your queries
	
	$query = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
              FROM Project.Bets AS b 
              GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
        $title = "Prediction Success of the Betting Companies";
	query_and_print_graph($query,$title,"Prediction Success");
?>

	<p>Blablabla.</p>

<?php
	// Page body. Write here your queries
	
	$query = "SELECT avg(ms.FullTimeGoals) AS FullTimeGoals, avg(ms.LeaguePoints) AS LeaguePoints, avg(ms.HalfTimeGoals) AS HalfTimeGoals, avg(ms.Shots) AS Shots, avg(ms.ShotsOnTarget) AS ShotsOnTarget , avg(ms.FoulsCommitted) AS Fouls, avg(ms.YellowCards) AS YellowCards, avg(ms.RedCards) AS RedCards
FROM Project.MatchStat AS ms
WHERE ms.HomeAway = 'H'";

        $title = "Prediction Success of the Betting Companies";
        query_and_print_table($query,$title,"Average Statistics of teams playing at home");
?>

<?php
	// Page body. Write here your queries
	
	$query = "SELECT avg(ms.FullTimeGoals) AS FullTimeGoals, avg(ms.LeaguePoints) AS LeaguePoints, avg(ms.HalfTimeGoals) AS HalfTimeGoals, avg(ms.Shots) AS Shots, avg(ms.ShotsOnTarget) AS ShotsOnTarget , avg(ms.FoulsCommitted) AS Fouls, avg(ms.YellowCards) AS YellowCards, avg(ms.RedCards) AS RedCards
FROM Project.MatchStat AS ms
WHERE ms.HomeAway = 'A'";
        $title = "Prediction Success of the Betting Companies";
	query_and_print_table($query,$title,"Average Statistics of teams playing away");
?>


<?php
    // Time series
    
    $query = "SELECT m.Season, avg(ms.LeaguePoints) FROM Project.Matches AS m, Project.MatchStat AS ms
WHERE m.MatchID = ms.MatchID AND ms.TeamID IN (SELECT * FROM (SELECT m.TeamID FROM Project.MatchStat AS m GROUP BY m.teamID ORDER BY avg(m.LeaguePoints) DESC LIMIT 1) AS temp1)
GROUP BY ms.TeamID, m.Season";

$query2 = "SELECT m.Season, avg(ms.LeaguePoints) FROM Project.Matches AS m, Project.MatchStat AS ms
WHERE m.MatchID = ms.MatchID AND ms.TeamID IN (SELECT * FROM (SELECT m.TeamID FROM Project.MatchStat AS m GROUP BY m.teamID ORDER BY avg(m.LeaguePoints) ASC LIMIT 1) AS temp1)
GROUP BY ms.TeamID, m.Season";

    $title = "Line";
query_and_print_series($query,$title,"Best Team");
?>

<?php
    // Time series

$query = "SELECT m.Season, avg(ms.LeaguePoints) FROM Project.Matches AS m, Project.MatchStat AS ms
WHERE m.MatchID = ms.MatchID AND ms.TeamID IN (SELECT * FROM (SELECT m.TeamID FROM Project.MatchStat AS m GROUP BY m.teamID ORDER BY avg(m.LeaguePoints) ASC LIMIT 1) AS temp1)
GROUP BY ms.TeamID, m.Season";

    $title = "Line";
query_and_print_series($query,$title,"Worst Team");
?>

	  
	</div>
	<div id="analysis" style="display: none">
	<h2>Analysis</h2>
	  
	<p>Blablabla.</p>

		</div>
<?php
	// Close connection
	mysql_close($link);
?>
