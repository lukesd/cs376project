1) Upload all the files to the website.
2) Setup the database, cf. mysql.php
3) Execute this SQL to setup your database tables:

		CREATE TABLE IF NOT EXISTS `battles` (
			`battle_id` bigint(20) unsigned NOT NULL auto_increment,
			`winner` bigint(20) unsigned NOT NULL,
			`loser` bigint(20) unsigned NOT NULL,
			`ip_address` varchar(255) NOT NULL,
			PRIMARY KEY  (`battle_id`),
			KEY `winner` (`winner`)
		) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
		
		
		CREATE TABLE IF NOT EXISTS `musics` (
			`music_id` bigint(20) unsigned NOT NULL auto_increment,
			`filename` varchar(255) NOT NULL,
			`score` int(10) unsigned NOT NULL default '1500',
			`wins` int(10) unsigned NOT NULL default '0',
			`losses` int(10) unsigned NOT NULL default '0',
			`group` int(10 ) unsigned NOT NULL,
			`session` int(10 ) unsigned NOT NULL,
			PRIMARY KEY  (`music_id`)
		) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

4) place all the musics in the /musics/ folder.
5) manually enter the musics in the database.