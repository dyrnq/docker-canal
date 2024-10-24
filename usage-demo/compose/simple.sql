DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
  `id` int PRIMARY KEY,
  `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_at` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;


insert into `person` (`id`, `last_name`, `first_name`, `address`, `city`) values (1, 'Li', 'Lily', '123 Main St', 'New York');
insert into `person` (`id`, `last_name`, `first_name`, `address`, `city`) values (20, '李', '小明', '南山区某街道某小区', '深圳');

delete from `person` where `id`=20;
insert into `person` (`id`, `last_name`, `first_name`, `address`, `city`) values (20, '李', '小明', '南山区某街道某小区', '深圳');


DROP TABLE IF EXISTS `tb_user`;
CREATE TABLE tb_user (
  id int NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_name varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户名称',
  create_time datetime(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间',
  update_time datetime(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '更新时间',
  PRIMARY KEY (id) USING BTREE,
  KEY create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='测试表';

insert into tb_user (user_name) values ('张三');
insert into tb_user (user_name) values ('李四');
insert into tb_user (user_name) values ('王五');
insert into tb_user (user_name) values ('赵六');

update tb_user set user_name='张三改' where id=1;
update tb_user set user_name='张三' where id=1;
