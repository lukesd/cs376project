<?php

// Calculate the expected % outcome
function expected($Rb, $Ra) {
	return 1/(1 + pow(10, ($Rb-$Ra)/400));
}

// Calculate the new winnner score
function win($score, $expected, $k = 24) {
	return $score + $k * (1-$expected);
}

// Calculate the new loser score
function loss($score, $expected, $k = 24) {
	return $score + $k * (0-$expected);
}

// Get the real IP address of the client
function getRealIpAddr()
{
    //Test if it is a shared client
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
      $ip = $_SERVER['HTTP_CLIENT_IP'];
    //Is it a proxy address
    }
    elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
      $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    }
    else {
      $ip = $_SERVER['REMOTE_ADDR'];
    }
    //The value of $ip at this point would look something like: "192.0.34.166"
    //$ip = ip2long($ip);
    //The $ip would now look something like: 1073732954
    return $ip;
}

?>