<?php
/*
* Title: Facemash-Alike Script
*
* Performance rating = [(Total of opponents' ratings + 400 * (Wins - Losses)) / score].
*/

include('mysql.php');
include('functions.php');

// Get random 2
$query="SELECT * FROM images ORDER BY RAND() LIMIT 0,2";
$result = @mysql_query($query);

while($row = mysql_fetch_object($result)) {
    $images[] = (object) $row;
}

// Get the top10
$result = mysql_query("SELECT *, ROUND(score/(1+(losses/wins))) AS performance FROM images ORDER BY ROUND(score/(1+(losses/wins))) DESC LIMIT 0,10");
while($row = mysql_fetch_object($result)) $top_ratings[] = (object) $row;

// Close the connection
mysql_close();
?>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Musicmash - CS 376</title>
    <style type="text/css">

    body, html {font-family:Arial, Helvetica, sans-serif;width:100%;margin:0;padding:0;text-align:center;}
    h1 {background-color:#600;color:#fff;padding:20px 0;margin:0;}
    a img {border:0;}
    td {font-size:11px;}
    .image {background-color:#eee;border:1px solid #ddd;border-bottom:1px solid #bbb;padding:5px;}

    </style>
</head>

<body>


    <h1>Musicmash - CS 376 Research Project</h1>
    <h3>Were we let in for our looks? No. Will we be judged on them? Yes.</h3>
    <h2>Who's hotter? Click to choose.</h2>

    <center>
        <table>
            <tr>
                <td valign="top" class="image"><a href="rate.php?winner=<?=$images[0]->image_id?>&loser=<?=$images[1]->image_id?>"><img src="images/<?=$images[0]->filename?>" /></a></td>
                <td valign="top" class="image"><a href="rate.php?winner=<?=$images[1]->image_id?>&loser=<?=$images[0]->image_id?>"><img src="images/<?=$images[1]->filename?>" /></a></td>
            </tr>
            <tr>
                <td>Won: <?=$images[0]->wins?>, Lost: <?=$images[0]->losses?></td>
                <td>Won: <?=$images[1]->wins?>, Lost: <?=$images[1]->losses?></td>
            </tr>
            <tr>
                <td>Score: <?=$images[0]->score?></td>
                <td>Score: <?=$images[1]->score?></td>
            </tr>
            <tr>
                <td>Expected: <?=round(expected($images[1]->score, $images[0]->score), 4)?></td>
                <td>Expected: <?=round(expected($images[0]->score, $images[1]->score), 4)?></td>
            </tr>
        </table>
    </center>

    <h2>Top Rated</h2>
    <center>
        <table>
            <tr>
                <? foreach($top_ratings as $key => $image) : ?>
                <td valign="top"><img src="images/<?=$image->filename?>" width="70" /></td>
            <? endforeach ?>
        </tr>
        <? /* Remove this to see the scoring
        <tr>
        <? foreach($top_ratings as $key => $image) : ?>
        <td valign="top">Score: <?=$image->score?></td>
        <? endforeach ?>
        </tr>
        <tr>
        <? foreach($top_ratings as $key => $image) : ?>
        <td valign="top">Performance: <?=$image->performance?></td>
        <? endforeach ?>
        </tr>
        <tr>
        <? foreach($top_ratings as $key => $image) : ?>
        <td valign="top">Won: <?=$image->wins?></td>
        <? endforeach ?>
        </tr>
        <tr>
        <? foreach($top_ratings as $key => $image) : ?>
        <td valign="top">Lost: <?=$image->losses?></td>
        <? endforeach ?>
        </tr>
        */ ?>
    </table>
</center>

</body>
</html>
