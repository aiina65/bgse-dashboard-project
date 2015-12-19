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
	
	  <p>In this section we carry out an initial analysis of our data, with the objective of understanding if we can treat all data as equal or if we have to subsample.</p>
	
	<p> The chart below shows the top 10 best teams of the history ranked according to the average league points they scored.</p>

<?php
    // Teams, winned games
    
    $query = "SELECT t.TeamName, avg(m.LeaguePoints)
              FROM Project.MatchStat AS m, Project.Teams AS t 
              WHERE m.TeamID = t.TeamID
              GROUP BY m.teamID ORDER BY avg(m.LeaguePoints) DESC LIMIT 10";
    $title = "Top Best Teams";
    query_and_print_graph($query,$title,"Average League Points");
?>

	
	<p>The chart below shows the results of a similar analysis, this time with the 10 worst teams of the history.</p>
	
<?php
	// Page body. Write here your queries
	
	$query = "SELECT t.TeamName, avg(m.LeaguePoints)
                  FROM Project.MatchStat AS m, Project.Teams AS t 
                  WHERE m.TeamID = t.TeamID 
                  GROUP BY m.teamID ORDER BY avg(m.LeaguePoints) ASC LIMIT 10";
        $title = "Top Worst Teams";
	query_and_print_graph($query,$title,"Average League Points");
?>


<p>Once we have seen the difference between best/worst teams, we are going to analyse the difference between teams playing home and away. It is interesting to notice that teams playing home in average win more and teams playing away commit more fouls.</p>
	
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

<p> In order to see if all the betting companies perform similary, we are interested in observing their performance.</p>
<p> The chart below shows the percentage of prediction succes of each betting company.</p>
<?php
	// Page body. Write here your queries
	
	$query = "SELECT b.CompanyCode AS CompanyCode, avg(b.PredictionSuccess) AS Prediction
              FROM Project.Bets AS b 
              GROUP BY b.CompanyCode ORDER BY avg(b.PredictionSuccess) DESC";
        $title = "Prediction Success of the Betting Companies";
	query_and_print_circular_graph($query,$title);
?>

<p>The following chart shows a similar analysis. This time, we plot the prediction accuracy per country.</p>
<?php
	// Page body. Write here your queries
	
	$query = "SELECT l.Country AS Country, avg(b.PredictionSuccess) AS Prediction
                  FROM Project.Bets AS b, Project.Matches AS m, Project.Leagues AS l
                  WHERE b.MatchID = m.MatchID AND m.LeagueID = l.LeagueID
                  GROUP BY l.Country ORDER BY avg(b.PredictionSuccess) DESC";
        $title = "Prediction Success of the Betting Companies per Country";
	query_and_print_circular_graph($query,$title);
?>

<p>Finally, we also want to see the historical evolution of teams. The chart below shows the average league points of four good teams in different seasons. </p>

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

<p>The previous charts show us that the betting companies are very similar accross teams and countries and we can use all the data in our next analysis.</p>

<p> In the next tab, we take this analysis further by implementing a betting recommendation engine and by regressing our data to try to predict the final outcome of a match.</p>
	  
	</div>
	<div id="analysis" style="display: none">
	<h2>Analysis</h2>
	  
  <p>Below, we show the betting recommendations (betting company - team pairs) obtained from the maximum matching algorithm. Notice that for each company, it is shown the team whose match result is more predictable. Then, when betting, the better option is to bet for the lowest betting odd of the match where that teams is playing.</p>

  <p>This table shows the most safe combination of betting companies - teams.</p>

  <?php
	$query = "SELECT * FROM Project.Matching";
	$title = "Recommendation: safe";
	query_and_print_table($query,$title);
	echo "";
?>

<p>This table shows a more risky combination of betting companies - teams, but with expected higher revenues.</p>
  <?php
	$query = "SELECT * FROM Project.MatchingRisk";
	$title = "Recommendation: risky";
	query_and_print_table($query,$title);
	echo "";
?>
<p> We want to look at how betting companies design their match odds based on pre-match factors, and then look at how these can be used to model the result.</p>

<p> We regressed, using a beta regression for match odds and a binomial GLM for match prediction, against the position in the table before the match and for the last season, dividing the standing into "ranks". Then also adding in this information for the opposition team. Goals scored and where the match was played, was also considered.</p>
	
<center><img src="betcoeffgraph.png" style="width: 40%"></center>

<center><img src="predcoeffgraph.png" style="width: 40%"></center>

<p> The graphs show in green the coefficients for winning, in red for losing, and in blue for drawing. There is a nice pattern formed, as expected. <\p>

<p> Then, looking at the accuracies over different leagues, it can be seen that these basic factors have a significant effect on the match and are effective predictors.</p>

<center><img src="Accuracy.png" style="width: 40%"></center>
		</div>
<?php
	// Close connection
	mysql_close($link);
?>
