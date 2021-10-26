时间类型设置为DATETIME(3)，防止java中的LocalDateTime存放数据时精度丢失
ALTER TABLE `xxx`.`table_aaa`  CHANGE COLUMN `begin_time` `begin_time` DATETIME(3) NULL DEFAULT NULL COMMENT '开始时间'
