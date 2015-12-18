<?php ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<head>
	<title>MyApp</title>    
	<link rel="stylesheet" type="text/css" href="style.css" />
</head>
<script>
/**
 * Given an element, or an element ID, blank its style's display
 * property (return it to default)
 */
function show(element) {
    if (typeof(element) != "object")	{
	element = document.getElementById(element);
    }
    
    if (typeof(element) == "object") {
	element.style.display = '';
    }
}

/**
 * Given an element, or an element ID, set its style's display property
 * to 'none'
 */
function hide(element) {
    if (typeof(element) != "object")	{
	element = document.getElementById(element);
    }
    
    if (typeof(element) == "object") {
	element.style.display = 'none';
    }
}

function show_content(optionsId) {
	var ids = new Array('home','data','analysis');
	show(optionsId);
	document.getElementById(optionsId + '_link').className = 'active';

	for (var i = 0; i < ids.length; i++)
	{
	    if (ids[i] == optionsId) continue;
	    hide(ids[i]);
	    document.getElementById(ids[i] + '_link').className = '';
	}
}
</script>
<body>
	<div id="header"><h1>Group 4: Historical football match data and betting odds</h1></div>

	<div id="menu">
		<a id="home_link" href="#" class="active" onclick="show_content('home'); return false;">Home</a> &middot;
		<a id="data_link" href="#" onclick="show_content('data'); update_data_charts(); return false;">Data</a> &middot;
		<a id="analysis_link" href="#" onclick="show_content('analysis'); return false;">Analysis</a> 
	</div>

	<div id="main">

		<div id="home">
			<h2>Home</h2>
			<h3>The challenge</h3>
			
  <p> Odds reflect the likelihood of a a certain event. In football matches, betting companies define three odds for each match: home win odd, away win odd and draw odd.  Each odd represents the amount that a person is going to earn if the team for which he bet wins. Therefore, the lowest odd is the most likely result. In order to maximize the revenues winned when betting in football matches, we would like to find which would be the most safe match to bet for in each betting company. Another way to also maximize the amount of money winned when gambling, is to predict the final outcome of a match.</p>
		       
			<ul style="list-style-type:circle">
																																																						       <li> The first objective can be achieved by developing a recommendation engine which, based on betting companies prediction success in previous matches it recommends what are the best matches to bet for in each betting company.</li>
  				<li> The second objective can be achieved by regressing match odds against factors.</li>
			</ul>
			
			<h3>The solution</h3>
						
			<p>We have addressed the above challenges in the following steps:</p>
				<ul style="list-style-type:circle">
  <li> First we have implemented two simple recommendation engines, based on the <b><a href="https://en.wikipedia.org/wiki/Push-relabel_maximum_flow_algorithm" target="_blank">Push relabel algorithm.</a></b>. Although this algorithm finds the maximum flow it can be easily changed to find the maximum matching in bipartite graphs. The difference between the two systems is the formula applied to compute the bets for each nodes: one model returns the most safe option and the other returns a more risky option with a higher revenue. This weights reflect the prediction success of each betting company predicting matches of each team. The output of the algorithms is a set of betting company and team pairs which can be interpreted as the teams whose matches are better predicted by each betting company. Then, when betting, the better option is to bet for the lowest betting odd in that match.</li>

					<li> To address the second part of the challenge, BLABLABLA.</li>
				</ul>
						
		</div>	

                <?php include 'data_and_analysis.php' ?>
	
	</div>

	<div id="footer">Project team: Kseniya Bout, Andreas Lloyd, Aina Lopez</div>

</body>
</html>
<?php ?>
