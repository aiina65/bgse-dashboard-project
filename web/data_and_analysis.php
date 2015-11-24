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
	
	$query = "SELECT 'FullTimeGoals' descrip, FullTimeGoals value
                  from (SELECT avg(ms.FullTimeGoals) AS FullTimeGoals FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp
                  union all
                  select 'LeaguePoints' descrip, LeaguePoints value
                  from (SELECT avg(ms.LeaguePoints) AS LeaguePoints FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp
                  union all
                  select 'HalfTimeGoals' descrip, HalfTimeGoals value
                  from (SELECT avg(ms.HalfTimeGoals) AS HalfTimeGoals FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp
                  union all
                  select 'Shots' descrip, Shots value 
                  from (SELECT avg(ms.Shots) AS Shots FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp
                  union all
                  select 'ShotsOnTarget' descrip, ShotsOnTarget value
                  from (SELECT avg(ms.ShotsOnTarget) AS ShotsOnTarget FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp
                  union all
                  select 'Fouls' descrip, Fouls value
                  from (SELECT avg(ms.FoulsCommitted) AS Fouls FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp
                  union all
                  select 'YellowCards' descrip, YellowCards value 
                  from (SELECT avg(ms.YellowCards) AS YellowCards FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp
                  union all
                  select 'RedCards' descrip, RedCards value
                  from (SELECT avg(ms.RedCards) AS RedCards FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'H') AS temp";

        $query2 = "SELECT 'FullTimeGoals' descrip, FullTimeGoals value
                  from (SELECT avg(ms.FullTimeGoals) AS FullTimeGoals FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp
                  union all
                  select 'LeaguePoints' descrip, LeaguePoints value
                  from (SELECT avg(ms.LeaguePoints) AS LeaguePoints FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp
                  union all
                  select 'HalfTimeGoals' descrip, HalfTimeGoals value
                  from (SELECT avg(ms.HalfTimeGoals) AS HalfTimeGoals FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp
                  union all
                  select 'Shots' descrip, Shots value 
                  from (SELECT avg(ms.Shots) AS Shots FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp
                  union all
                  select 'ShotsOnTarget' descrip, ShotsOnTarget value
                  from (SELECT avg(ms.ShotsOnTarget) AS ShotsOnTarget FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp
                  union all
                  select 'Fouls' descrip, Fouls value
                  from (SELECT avg(ms.FoulsCommitted) AS Fouls FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp
                  union all
                  select 'YellowCards' descrip, YellowCards value 
                  from (SELECT avg(ms.YellowCards) AS YellowCards FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp
                  union all
                  select 'RedCards' descrip, RedCards value
                  from (SELECT avg(ms.RedCards) AS RedCards FROM Project.MatchStat AS ms WHERE ms.HomeAway = 'A') AS temp";

        $title = "Match Statistics";
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
	
	$query = "SELECT  b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Belgian'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query2 = "SELECT  b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Dutch'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query3 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'English'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query4 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'French'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query5 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'German'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query6 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Greek'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query7 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Italian'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query8 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Portuguese'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query9 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Scottish'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query10 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Spanish'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
	$query11 = "SELECT b.CompanyCode, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID AND l.Country = 'Turkish'
                  GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";


        $title = "Prediction Success of the Betting Companies";
	query_and_print_group_graph($query,$query2,$query3,$query4,$query5,$query6,$query7,$query8,$query9,$query10,$query11,$title,$ylabel)
?>

	<p>Blablabla.</p>


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
