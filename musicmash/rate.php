<?php


include('mysql.php');
include('functions.php');

$ip_address = getRealIpAddr();

// If rating - update the database
if ($_GET['winner'] && $_GET['loser'] && $ip_adress) {

	// Get the winner
	$result = mysql_query("SELECT * FROM musics WHERE image_id = ".$_GET['winner']." ");
	$winner = mysql_fetch_object($result);


	// Get the loser
	$result = mysql_query("SELECT * FROM musics WHERE image_id = ".$_GET['loser']." ");
	$loser = mysql_fetch_object($result);


	// Update the winner score
	$winner_expected = expected($loser->score, $winner->score);
	$winner_new_score = win($winner->score, $winner_expected);
		//test print "Winner: ".$winner->score." - ".$winner_new_score." - ".$winner_expected."<br>";
	mysql_query("UPDATE musics SET score = ".$winner_new_score.", wins = wins+1 WHERE image_id = ".$_GET['winner']);


	// Update the loser score
	$loser_expected = expected($winner->score, $loser->score);
	$loser_new_score = loss($loser->score, $loser_expected);
		//test print "Loser: ".$loser->score." - ".$loser_new_score." - ".$loser_expected."<br>";
	mysql_query("UPDATE musics SET score = ".$loser_new_score.", losses = losses+1  WHERE image_id = ".$_GET['loser']);


	// Insert battle
	mysql_query("INSERT INTO battles SET winner = ".$_GET['winner'].", loser = ".$_GET['loser'].", ip_address = ".$ip_address." ");


	// Back to the frontpage
	header('location: /');
	
}


?>