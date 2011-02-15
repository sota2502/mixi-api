CREATE TABLE `token` (
  `code` varchar(40) PRIMARY KEY NOT NULL,
  `access_token` varchar(40) NOT NULL,
  `refresh_token` varchar(40) NOT NULL,
  `expire` timestamp NOT NULL
);
CREATE INDEX `idx1` ON token(`expire`);

