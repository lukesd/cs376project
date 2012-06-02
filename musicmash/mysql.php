<?php

// Mysql settings

$user		= "";
$password	= "";
$database	= "";
$host		= "";

mysql_connect($host, $user, $password);
mysql_select_db($database) or die( "Unable to select database");

?>