CREATE DATABASE /*!32312 IF NOT EXISTS*/ `mytest2` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;
USE `mytest2`;
SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for stuff
-- ----------------------------
DROP TABLE IF EXISTS `stuff`;
CREATE TABLE `stuff` (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);
