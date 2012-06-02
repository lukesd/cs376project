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
    if (!empty($_SERVER['HTTP_CLIENT_IP']))   //check ip from share internet
    {
      $ip = $_SERVER['HTTP_CLIENT_IP'];
    }
    elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))   //to check ip is pass from proxy
    {
      $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    }
    else
    {
      $ip = $_SERVER['REMOTE_ADDR'];
    }
    return $ip;
}

?>