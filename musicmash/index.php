<?php
/*
* Title: Facemash-Alike Script
*
* Performance rating = [(Total of opponents' ratings + 400 * (Wins - Losses)) / score].
*/

include('mysql.php');
include('functions.php');


// Get random elements
$query1 = "SELECT * FROM musics WHERE `group` = 2 ORDER BY RAND() LIMIT 0,1";
$result1 = @mysql_query($query1);
$query2 = "SELECT * FROM musics WHERE `group` = 4 ORDER BY RAND() LIMIT 0,1";
$result2 = @mysql_query($query2);

while($row = mysql_fetch_object($result1)) {
    $musics[] = (object) $row;
}

while($row = mysql_fetch_object($result2)) {
    $musics[] = (object) $row;
}


// Get the top10
// $result = mysql_query("SELECT *, ROUND(score/(1+(losses/wins))) AS performance FROM musics ORDER BY ROUND(score/(1+(losses/wins))) DESC LIMIT 0,10");
// while($row = mysql_fetch_object($result)) $top_ratings[] = (object) $row;

// Close the connection
mysql_close();

$ip = getRealIpAddr();
?>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>MusicMash - CS 376 Research Project</title>
    <style type="text/css">

    body, html {
        font-family: Arial, Helvetica, sans-serif;
        width: 100%;
        margin: 0;
        padding: 0;
        text-align: center;
    }

    h1 {background-color: #600;
        color: #fff;
        padding: 20px 0;
        margin: 0;
    }

    a img {
        border: 0;
    }

    td {
        /*        font-size: 11px;*/
        text-align: center;
    }

    .player {
        background-color: #eee;
        border: 1px solid #ddd;
        border-bottom: 1px solid #bbb;
        padding: 5px;
    }

    </style>
</head>

<body>

    <h1>MusicMash &ndash; CS 376 Research Project</h1>
    <h2>What music is the best? Click to choose.</h2>
    <p>
        Please listen carefully both musics before voting, or the results wouldn't be accurate.
    </p>

    <center>
        <table>
            <tr>
                <td valign="top" class="player">
                    <audio controls="controls">
                        <source src="musics/<?=$musics[0]->filename?>" type="audio/wav"></source>
                        Your browser does not support the audio element.
                    </audio>
                </td>
                <td valign="top" class="player">
                    <audio controls="controls">
                        <source src="musics/<?=$musics[1]->filename?>" type="audio/wav"></source>
                        Your browser does not support the audio element.
                    </audio>
                </td>
            </tr>
            <tr>
                <td>
                    <a href="rate.php?winner=<?=$musics[0]->music_id?>&amp;loser=<?=$musics[1]->music_id?>">This one is better
                    </a>
                </td>
                <td>
                    <a href="rate.php?winner=<?=$musics[1]->music_id?>&amp;loser=<?=$musics[0]->music_id?>">
                        This one is better
                    </a>
                </td>
            </tr>
            <? /* Remove this to see the scoring
            <tr>
            <td><?=$musics[0]->filename?></td>
            <td><?=$musics[1]->filename?></td>
            </tr>
            <tr>
            <td>Won: <?=$musics[0]->wins?>, Lost: <?=$musics[0]->losses?></td>
            <td>Won: <?=$musics[1]->wins?>, Lost: <?=$musics[1]->losses?></td>
            </tr>
            <tr>
            <td>Score: <?=$musics[0]->score?></td>
            <td>Score: <?=$musics[1]->score?></td>
            </tr>
            <tr>
            <td>Expected: <?=round(expected($musics[1]->score, $musics[0]->score), 4)?></td>
            <td>Expected: <?=round(expected($musics[0]->score, $musics[1]->score), 4)?></td>
            </tr>
            */ ?>
        </table>
    </center>


    <? /* Remove this to see the scoring
    <h2>Top Rated</h2>
    <center>
    <table>
    <tr>
    <? foreach($top_ratings as $key => $music) : ?>
    <td valign="top"><?=$music->filename?>/td>
    <? endforeach ?>
    </tr>
    <tr>
    <? foreach($top_ratings as $key => $music) : ?>
    <td valign="top">Score: <?=$music->score?></td>
    <? endforeach ?>
    </tr>
    <tr>
    <? foreach($top_ratings as $key => $music) : ?>
    <td valign="top">Performance: <?=$music->performance?></td>
    <? endforeach ?>
    </tr>
    <tr>
    <? foreach($top_ratings as $key => $music) : ?>
    <td valign="top">Won: <?=$music->wins?></td>
    <? endforeach ?>
    </tr>
    <tr>
    <? foreach($top_ratings as $key => $music) : ?>
    <td valign="top">Lost: <?=$music->losses?></td>
    <? endforeach ?>
    </tr>
    </table>
    </center>
    */ ?>
</body>
</html>
