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
	
	$query = "SELECT b.CompanyCode AS CompanyCode, avg(b.PredictionSuccess) AS Prediction
              FROM Project.Bets AS b 
              GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
        $title = "Prediction Success of the Betting Companies";
	query_and_print_circular_graph($query,$title);
?>

	<p>Blablabla.</p>
<?php
	// Page body. Write here your queries
	
	$query = "SELECT l.Country AS Country, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID
                  GROUP BY l.Country ORDER BY avg(b.PredictionSuccess) DESC";
        $title = "Prediction Success of the Betting Companies per Country";
	query_and_print_circular_graph($query,$title);
?>

	<p>Blablabla.</p>



<?php
    // Time series
    
    $query = "SELECT m.Season, avg(ms.LeaguePoints) FROM Project.Matches AS m, Project.MatchStat AS ms
WHERE m.MatchID = ms.MatchID AND ms.TeamID IN (SELECT t.TeamID FROM Project.Teams AS t WHERE t.TeamName= 'Olympiakos' ) GROUP BY ms.TeamID, m.Season";

    $query2 = "SELECT m.Season, avg(ms.LeaguePoints) FROM Project.Matches AS m, Project.MatchStat AS ms
WHERE m.MatchID = ms.MatchID AND ms.TeamID IN (SELECT t.TeamID FROM Project.Teams AS t WHERE t.TeamName= 'Bayern Munich' ) GROUP BY ms.TeamID, m.Season";
    $query3 = "SELECT m.Season, avg(ms.LeaguePoints) FROM Project.Matches AS m, Project.MatchStat AS ms
WHERE m.MatchID = ms.MatchID AND ms.TeamID IN (SELECT t.TeamID FROM Project.Teams AS t WHERE t.TeamName= 'Man United' ) GROUP BY ms.TeamID, m.Season";

    $query4 = "SELECT m.Season, avg(ms.LeaguePoints) FROM Project.Matches AS m, Project.MatchStat AS ms
WHERE m.MatchID = ms.MatchID AND ms.TeamID IN (SELECT t.TeamID FROM Project.Teams AS t WHERE t.TeamName= 'Barcelona' ) GROUP BY ms.TeamID, m.Season";

    $title = "Historical evolution of some teams";
query_and_print_more_series($query,$query2,$query3,$query4, $title,"Olympiakos", "Bayern Munich", "Man United", "Barcelona");
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

  <?php
	$query = "SELECT * FROM Project.Matching";
	$title = "Recommendation: safe";
	query_and_print_table($query,$title);
	echo "";
?>

  <?php
	$query = "SELECT * FROM Project.MatchingRisk";
	$title = "Recommendation: risky";
	query_and_print_table($query,$title);
	echo "";
?>

		</div>
<?php
	// Close connection
	mysql_close($link);
?>
