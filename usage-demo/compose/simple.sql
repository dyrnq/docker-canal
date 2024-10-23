DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
  `id` int PRIMARY KEY,
  `last_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `first_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;


insert into `person` (`id`, `last_name`, `first_name`, `address`, `city`) values (1, 'Li', 'Lily', '123 Main St', 'New York');
insert into `person` (`id`, `last_name`, `first_name`, `address`, `city`) values (20, '李', '小明', '南山区某街道某小区', '深圳');
