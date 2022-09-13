CREATE TABLE IF NOT EXISTS `licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type` (`type`)
);

INSERT INTO `licenses` (`id`, `type`, `label`) VALUES
(1, 'dmv', 'Teoriakoe'),
(2, 'drive', 'Autokortti'),
(3, 'drive_bike', 'Moottoripyöräkortti'),
(4, 'drive_truck', 'Rekkakortti');
