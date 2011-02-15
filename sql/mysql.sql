--
-- Table structure for table `token`
--

DROP TABLE IF EXISTS `token`;
CREATE TABLE `token` (
  `code` varchar(40) NOT NULL,
  `access_token` varchar(40) NOT NULL,
  `refresh_token` varchar(40) NOT NULL,
  `expire` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`code`),
  KEY `idx1` (`expire`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
