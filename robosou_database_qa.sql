-- MySQL dump 10.19  Distrib 10.3.29-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: robosou_database_qa
-- ------------------------------------------------------
-- Server version	10.3.29-MariaDB-0ubuntu0.20.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
/*!50003 CREATE*/ /*!50017 DEFINER=`qa`@`%`*/ /*!50003 trigger trigger_associate_delivery_configuration_robot_after_insert
    after insert on delivery_robot for each row
    insert into delivery_robot_configuration (delivery_configuration_id, delivery_robot_id)
    values ((
        select
            dcd.delivery_configuration_id
        from delivery_robot dr
        inner join robot r on dr.robot_id = r.id
        inner join owner o on r.owner_id = o.id
        inner join delivery_configuration_default dcd on o.id = dcd.owner_id
        where
            dr.id = new.id
        limit 1
    ), new.id) */$$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping routines for database 'robosou_database_qa'
--
/*!50003 DROP PROCEDURE IF EXISTS `create_delivery_configuration_for_all_delivery_robots` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `create_delivery_configuration_for_all_delivery_robots`()
begin
    declare delivery_robot_id int;
    set delivery_robot_id = 0;
    while delivery_robot_id is not null do
       set delivery_robot_id = (
            select dr.id from delivery_robot dr
            left join delivery_notification_configuration dc on dr.id = dc.delivery_robot_id
            where dc.id is null
            limit 1
       );
       if (delivery_robot_id is not null) then
            insert delivery_notification_configuration (
               delivery_robot_id,
               battery_save,
               battery_notification,
               arrival_save,
               arrival_notification,
               departure_save,
               departure_notification,
               connection_save,
               connection_notification,
               waiting_time,
               minimal_level_battery
            )
            values (delivery_robot_id,0,0,0,0,0,0,0,0,0,0);
       end if;
    end while;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_pd1_robot` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `create_pd1_robot`(in owner_id int)
begin
    declare robot_id int;
    declare pudu_cloud_user_id int;
    declare serial_number varchar(100);
    declare mac_address varchar(100);
    declare robot_name varchar(100);
    declare robot_group varchar(100);
    declare pudu_cloud_robot_id varchar(100);

#     DEFAULT VALUES
    set robot_name = 'PD1';
    set serial_number = 'd4124386fdb6';
    set mac_address = '9762183844642';
    set robot_group = 'C5X2uUYQSi6pMVOZ_0_5836';
    set pudu_cloud_robot_id ='d4124386fdb6';

    set pudu_cloud_user_id = (select id from pudu_cloud_user pcu where pcu.owner_id = owner_id limit 1);

    start transaction;
    insert into robot (owner_id, nickname, serial_number, mac_address, robot_type)
    values (owner_id, robot_name, serial_number, mac_address, 'pudu');

    set robot_id = (select id from robot order by id desc limit 1);

    insert into pudu_robot (pudu_cloud_user_id, robot_group_identifier, connection_status, battery_level, pudu_cloud_identifier, robot_id)
    values (pudu_cloud_user_id, robot_group, 0, 0, pudu_cloud_robot_id, robot_id);

    insert into delivery_robot (robot_id, number_trays, estimation_multiplier) values (robot_id, 4, 1.1);
    commit;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_pre_condition_for_tests` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `create_pre_condition_for_tests`()
begin
    declare owner_id int;
    declare owner_user_id int;
    declare pudu_cloud_user_id int;
    declare cloud_id int;
    declare owner_email varchar(100);
    declare owner_passwd varchar(100);
    declare owner_device_identifier varchar(100);
    declare owner_device_secret varchar(100);
    declare i int;
    declare j int;
    declare number_subordinates int;
    declare subordinate_user_id int;
    declare subordinate_id int;
    declare subordinate_passwd varchar(100);
    declare profile_id int;
    declare number_trays_for_each_pudu_robot int;
    declare number_trays_for_each_bella_robot int;
    declare number_pudu_robots int;
    declare number_bella_robots int;
    declare number_table_targets int;
    declare number_folders int;
    declare cloud_folder_id int;
    declare number_programming_advertisings int;

    set owner_email = 'habibs@habibs.com';
    set owner_passwd = '123456';
    set owner_device_identifier = '9762183844642';
    set owner_device_secret = '0ef3be3cf38123270888c3a0c280e421';
    set number_subordinates = 1;
    set subordinate_passwd = '@A32fg)k31j,sag,,';
    set number_trays_for_each_bella_robot = 4;
    set number_trays_for_each_pudu_robot = 4;
    set number_bella_robots = 10;
    set number_pudu_robots = 15;
    set number_table_targets = 30;
    set number_folders = 10;
    set number_programming_advertisings = 15;

    call reset_database();

    start transaction;
#     CREATE A OWNER
    insert into user (id, email, password) VALUES (1, owner_email, owner_passwd);
    set owner_user_id = (select id from user order by id desc limit 1);
    if (owner_user_id is null) then
        set owner_user_id = 0;
    end if;

    insert into person (id, user_id, name, cpf_cnpj, contact_phone, birth_date, photo_path)
    values (1, owner_user_id, 'owner', '620.546.789-54', '85564654984','1980-10-10', '');

    insert into owner (id, user_id) values (1, owner_user_id);
    set owner_id = (select id from owner order by id desc limit 1);
    if (owner_id is null) then
        set owner_id = 0;
    end if;

    insert into delivery_configuration (id, owner_id, request_number_configuration, ticket_number_configuration, target_name_configuration, sender_name_configuration, title, receivement_screen_title, starting_screen_title)
    values (1, owner_id, 2, 2, 2, 2,'default', '', '');

    insert into delivery_configuration_default (id, owner_id, delivery_configuration_id)
    values (1, owner_id, (select id from delivery_configuration order by id desc limit 1));

    set i = 0;
    while i < number_table_targets do
        insert into table_target (id, name, pudu_cloud_identifier, owner_id, table_target_status_id)
        values (i + 1, concat('m', i + 1), concat('m', i + 1), owner_id, 1);
        set i = i + 1;
    end while;

    insert into pudu_cloud_user (id, device_identifier, device_secret, owner_id)
    values (1, owner_device_identifier, owner_device_secret, owner_id);
    set pudu_cloud_user_id = (select id from pudu_cloud_user order by id desc limit 1);
    if (pudu_cloud_user_id is null) then
        set pudu_cloud_user_id = 0;
    end if;

    insert into cloud (id, owner_id) VALUES (1, owner_id);
    set cloud_id = (select id from cloud order by id desc limit 1);

    set i = 0;
    while i  < number_folders do
        insert cloud_folder (name, cloud_id, code)
        values (concat('folder_', i + 1), cloud_id, concat('folder_', i + 1));
        select id into cloud_folder_id from cloud_folder order by id desc limit 1;
        set j = 1;
        while j < 5 do
            insert cloud_file (name, extension, cloud_file_type_id, cloud_folder_id, code, device_path, path)
            values
            (concat('file_', i, j), 'jpg', 1, cloud_folder_id, concat('file_', i, j), concat('sys/class/', i, j), concat('wwwroot/upload',i,'/',j));
            set j = j + 1;
        end while;
        set i = i + 1;
    end while;

    insert into profile (id, name, owner_id, enabled)
    values
        (1,'profile_test_1', owner_id, 1),
        (2,'profile_test_2', owner_id, 1),
        (3,'profile_test_3', owner_id, 1),
        (4,'profile_test_4', owner_id, 1),
        (5,'profile_test_5', owner_id, 0)
    ;

    insert into profile_permission (id, profile_id, permission_id)
    values
           (1, 1, 1),
           (2, 1, 2),
           (3, 1, 3),
           (4, 1, 4),
           (5, 1, 5),
           (6, 1, 6),
           (7, 2, 1),
           (8, 3, 1),
           (9, 3, 4),
           (10, 3, 5),
           (11, 3, 10),
           (12, 4, 2),
           (13, 4, 6),
           (14, 4, 7),
           (15, 4, 8)
    ;

#     CREATE SUBORDINATES
    set i = 1;
    while i < number_subordinates do
        insert into user (id, email, password)
        values (
            i + 1,
            concat('subordinate_test_', i, '@test.com'),
            subordinate_passwd
        );
        set subordinate_user_id = (select id from user order by id desc limit 1);
        if (subordinate_user_id is null) then
            set subordinate_user_id = 0;
        end if;

        set profile_id = if (i % 2 = 1, 1, 2);

        insert into subordinate (id, user_id, owner_id, profile_id, name)
        values (
            i,
            subordinate_user_id,
            owner_id,
            profile_id,
            concat('subordinate_test_', i)
        );
        set subordinate_id = (select id from subordinate order by id desc limit 1);
        if (subordinate_id is null) then
            set subordinate_id = 0;
        end if;
        set j = 1;
        while j < (number_table_targets - 2) do
            insert table_target_subordinate (table_target_id, subordinate_id)
            values (j, subordinate_id);
            set j = j + 1;
        end while;
        set i = i + 1;
    end while;
#     REGISTER ROBOTS
#     call create_pd1_robot(owner_id);
#     call register_bella_robots(number_bella_robots,owner_id,number_trays_for_each_bella_robot);
#     call register_pubu_robots(number_pudu_robots,owner_id,number_trays_for_each_pudu_robot);
    set i = 0;
    while i < number_programming_advertisings do
        call create_programming_advertising(owner_id, 4);
        set i = i + 1;
    end while;
    commit;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_programming_advertising` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `create_programming_advertising`(IN owner_id int, IN screens_number int)
begin
    declare i int;
    declare advertising_last_id int;
    declare screen_id int;
    declare advertising_id int;
    select id into advertising_last_id from advertising order by id desc limit 1;
    if (advertising_last_id is null) then
        insert into advertising (name) values ('advertising_test_1');
    else
        insert into advertising (name) values (concat('advertising_test_', advertising_last_id + 1));
    end if;

    set advertising_id = (select id from advertising order by id desc limit 1);
    set advertising_id = if(advertising_id is null, 0, advertising_id);

    set i = 1;
    while i < screens_number do
        insert into screen (name, time, enable_back, enable_next, enable_answer, screen_transition_mode_id)
        values (concat('screen_', i), 100 + i, 1, 0, 1, 1);
        set screen_id = (select id from screen  order by id desc limit 1);
        set screen_id = if(screen_id is null, 0, screen_id);
        insert into screen_advertising (advertising_id, `index`, colorCode, screen_id)
        values (advertising_id, 0, '#color_code', screen_id);
        set i = i + 1;
    end while;
    insert into programming_advertising (advertising_id, owner_id) values (advertising_id, owner_id);
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds`()
BEGIN
    call fill_seeds_amazon_polly_credentials();
    call fill_seeds_permission();
    call fill_seeds_menu_item_type();
    call fill_seeds_cloud_file_type();
    call fill_seeds_background_type();
    call fill_seeds_table_target_status();
    call fill_seeds_system_settings();
    call fill_seeds_screen_transition_mode();
    call fill_seeds_delivery_status();
    call fill_seeds_delivery_type();
    call fill_seeds_tray_status();
    call fill_seeds_delivery_field_configuration_type();
    call fill_seeds_delivery_configuration_speaking_type();
    call fill_seeds_delivery_configuration_speaking_engine();
END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_amazon_polly_credentials` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_amazon_polly_credentials`()
BEGIN
        INSERT
            amazon_polly_credentials (id, aws_secret_access_key, aws_access_key_id)
        VALUES
            (1,'0xBwMpeyF5mkEzuU2K6h9whcLr1wMMW395fQGZ2x', 'AKIAY7SORHFDOPOTMCVP')
        ;
END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_background_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_background_type`()
BEGIN
        INSERT
            background_type (id, name)
        VALUES
            (1, 'NONE'),
            (2, 'VIDEO'),
            (3, 'IMAGE'),
            (4, 'AUDIO');
    END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_cloud_file_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_cloud_file_type`()
BEGIN
        INSERT
            cloud_file_type (id, name)
        VALUES
            (1, 'NONE'),
            (2, 'VIDEO'),
            (3, 'IMAGE'),
            (4, 'AUDIO')
        ;
    END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_delivery_configuration_speaking_engine` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_delivery_configuration_speaking_engine`()
begin
    insert into delivery_configuration_speaking_engine (id, description)
    values
        (1, 'TTS'),
        (2, 'AMAZON POLLY')
    ;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_delivery_configuration_speaking_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_delivery_configuration_speaking_type`()
begin
    insert into delivery_configuration_speaking_type (id, description)
    values
        (1, 'INITIAL'),
        (2, 'FINAL')
    ;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_delivery_field_configuration_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_delivery_field_configuration_type`()
begin
    insert into delivery_field_configuration_type(id, description)
    values
        (1, 'ALLOWS REGISTRATION FOR SUBORDINATE AND ALLOWS ONLY SHOWING FOR CUSTOMER.'),
        (2, 'ALLOWS REGISTRATION FOR SUBORDINATE AND ALLOWS SHOWING AND SPEAKING FOR CUSTOMER.'),
        (3, 'NOT ALLOWS REGISTRATION FOR SUBORDINATE AND NOT ALLOWS SHOWING OR SPEAKING FOR CUSTOMER.')
    ;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_delivery_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_delivery_status`()
begin
    insert delivery_status (id, description)
    values
       (1,'DELIVERED'),
       (2,'UNDELIVERED')
    ;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_delivery_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_delivery_type`()
begin
    insert delivery_type (id, description)
    values
          (1, 'CLEANING'),
          (2, 'DELIVERY')
    ;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_menu_item_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_menu_item_type`()
BEGIN
        INSERT
            menu_item_type (id, description)
        VALUES
            (5, 'ADVERTISING'),
            (6, 'CAMERA ENGAGEMENT'),
            (7, 'SELFIE FACE'),
            (8, 'STORE MAP')
        ;
    END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_permission` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_permission`()
BEGIN
        INSERT
            permission (id, name)
        VALUES
            (1,'tabletNotification'),
            (2,'robotNotification'),
            (3,'callRobot'),
            (4,'deliverySetting'),
            (5,'base'),
            (6,'account'),
            (7,'programming'),
            (8,'settings'),
            (9,'cloud'),
            (10,'performance')
        ;
    END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_screen_transition_mode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_screen_transition_mode`()
begin
    insert into screen_transition_mode (id, description)
    values
        (1, 'NONE'),
        (2, 'CAROUSEL'),
        (3, 'SEQUENCE'),
        (4, 'RANDOM');
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_system_settings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_system_settings`()
begin
    insert system_settings (id, default_number_trays)
    values (1, 8);
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_table_target_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_table_target_status`()
begin
    insert table_target_status (id, description) values
       (1, 'EMPTY'),
       (2, 'BUSY'),
       (3, 'SERVED'),
       (4, 'NEEDING TO BE CLEANED'),
       (5, 'CLEAN');
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `fill_seeds_tray_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `fill_seeds_tray_status`()
begin
   insert into tray_status (id, description)
   values
        (1, 'Free'),
        (2, 'Await'),
        (3, 'OnTheWay'),
        (4, 'Arrived'),
        (5, 'Cancel'),
        (6, 'Complete')
   ;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_bella_robot` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `register_bella_robot`(IN ownerId int, IN traysNumber int)
BEGIN
    DECLARE puduCloudUserId INT;
    DECLARE robotId INT;
    DECLARE bellaRobotId INT;
    DECLARE deliveryRobotId INT;
    DECLARE i INT;
    DECLARE robotName varchar(150);
    DECLARE defaultNumberTrays INT;
    DECLARE lastRobotId INT;

    SET puduCloudUserId = (SELECT id FROM pudu_cloud_user WHERE owner_id = ownerId LIMIT 1);
    IF puduCloudUserId IS NULL THEN
        set puduCloudUserId = 0;
    end if;
    set lastRobotId = (SELECT id FROM robot ORDER BY id DESC LIMIT 1);

    SET robotName = CONCAT('robot_test_@', if(lastRobotId is null, 1, lastRobotId + 1));
    START TRANSACTION;
        INSERT robot (owner_id, nickname, serial_number, mac_address, robot_type)
        VALUES (ownerId, robotName, robotName, robotName, 'bella');
        SET robotId = (SELECT id FROM robot ORDER BY id DESC LIMIT 1);

        INSERT bella_robot ( pudu_cloud_user_id, robot_group_identifier, connection_status, battery_level, pudu_cloud_identifier,  robot_id)
        VALUES (puduCloudUserId, robotName, 1, 100,  robotName, robotId);
        SET bellaRobotId = (SELECT id FROM bella_robot ORDER BY id DESC LIMIT 1);

        INSERT bella_tablet ( serial_number,  mac_address, bella_robot_id)
        VALUES ( robotName, robotName, bellaRobotId);

        INSERT promoter_robot (robot_id)
        VALUES (robotId);

        INSERT delivery_robot (robot_id, number_trays)
        VALUES (robotId, traysNumber);
        SET deliveryRobotId = (SELECT id FROM delivery_robot ORDER BY id DESC LIMIT 1);
        IF (deliveryRobotId is null) then
            set deliveryRobotId = 0;
        end if;

        INSERT delivery_notification_configuration (delivery_robot_id, battery_save, battery_notification, arrival_save, arrival_notification, departure_save, departure_notification, connection_save, connection_notification, waiting_time, minimal_level_battery, pudu_cloud_robot_id)
        VALUES (deliveryRobotId,0,0,0,0,0,0,0,0,0,0,robotName);

        SET defaultNumberTrays = (SELECT default_number_trays from system_settings LIMIT 1);
        SET i = 0;
        WHILE (i < defaultNumberTrays) DO
            INSERT tray (tray_status_id, delivery_robot_id)
            VALUES (1, deliveryRobotId);
            SET i = i + 1;
        END WHILE;
    COMMIT;
END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_bella_robots` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `register_bella_robots`(IN number_robots int, IN owner_id int, IN trays_number int)
begin
    declare i int;
    set i = 0;
    while i < number_robots do
        call register_bella_robot(owner_id, trays_number);
        set i = i + 1;
    end while;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_notifications` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `register_notifications`(IN robotId int, IN notificationNumber int)
BEGIN
    declare i int;
    set i = 0;
    START TRANSACTION;
        while i < notificationNumber do
			  INSERT INTO notification (body, title, type, date, time, pudu_cloud_robot_id)
				VALUES (CONCAT('body', CAST(i AS CHAR)), CONCAT('title', CAST(i AS CHAR)), 1, CURDATE(), CURTIME(), robotId);
			  set i = i + 1;
		end while;
    commit;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_pubu_robots` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `register_pubu_robots`(IN number_robots int, IN owner_id int, IN trays_number int)
begin
    declare i int;
    set i = 0;
    while i < number_robots do
        call register_pudu_robot(owner_id, trays_number);
        set i = i + 1;
    end while;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `register_pudu_robot` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `register_pudu_robot`(IN ownerId int, IN traysNumber int)
BEGIN
    DECLARE puduCloudUserId INT;
    DECLARE robotId INT;
    DECLARE puduRobotId INT;
    DECLARE deliveryRobotId INT;
    DECLARE i INT;
    DECLARE robotName varchar(150);
    DECLARE defaultNumberTrays INT;
    DECLARE lastRobotId INT;

    SET puduCloudUserId = (SELECT id FROM pudu_cloud_user WHERE owner_id = ownerId LIMIT 1);
    IF puduCloudUserId IS NULL THEN
        set puduCloudUserId = 0;
    end if;
    set lastRobotId = (SELECT id FROM robot ORDER BY id DESC LIMIT 1);

    SET robotName = CONCAT('robot_test_@', if(lastRobotId is null, 1, lastRobotId + 1));
    START TRANSACTION;
        INSERT robot (owner_id, nickname, serial_number, mac_address, robot_type)
        VALUES (ownerId, robotName, robotName, robotName, 'pudu');
        SET robotId = (SELECT id FROM robot ORDER BY id DESC LIMIT 1);

        INSERT pudu_robot ( pudu_cloud_user_id, robot_group_identifier, connection_status, battery_level, pudu_cloud_identifier,  robot_id)
        VALUES (puduCloudUserId, robotName, 1, 100,  robotName, robotId);
        SET puduRobotId = (SELECT id FROM pudu_robot ORDER BY id DESC LIMIT 1);

        INSERT pudu_tablet ( serial_number,  mac_address, pudu_robot_id)
        VALUES ( robotName, robotName, puduRobotId);

        INSERT promoter_robot (robot_id)
        VALUES (robotId);

        INSERT delivery_robot (robot_id, number_trays)
        VALUES (robotId, traysNumber);
        SET deliveryRobotId = (SELECT id FROM delivery_robot ORDER BY id DESC LIMIT 1);

        INSERT delivery_notification_configuration (delivery_robot_id, battery_save, battery_notification, arrival_save, arrival_notification, departure_save, departure_notification, connection_save, connection_notification, waiting_time, minimal_level_battery, pudu_cloud_robot_id)
        VALUES (deliveryRobotId,0,0,0,0,0,0,0,0,0,0,robotName);

        SET defaultNumberTrays = (SELECT default_number_trays from system_settings LIMIT 1);
        SET i = 0;
        WHILE (i < defaultNumberTrays) DO
            INSERT tray (tray_status_id, delivery_robot_id)
            VALUES (1, deliveryRobotId);
            SET i = i + 1;
        END WHILE;
    COMMIT;
END $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reset_database` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER $$
CREATE DEFINER=`qa`@`%` PROCEDURE `reset_database`()
begin
    declare current_table varchar(150) default '';
    declare i int default 1;
    declare truncate_tables_command text default '';
    start transaction;
    set foreign_key_checks = 0;
    while current_table is not null do
        set current_table = (
            select
                TABLE_NAME
            from information_schema.TABLES
            where
                  TABLE_SCHEMA = 'robosou_database_qa'
                  and TABLE_TYPE = 'BASE TABLE'
            limit i,1
        );
        if (current_table is not null) then
            set truncate_tables_command = concat('truncate table ', current_table);
            prepare truncate_tables_query from truncate_tables_command;
            execute truncate_tables_query;
        end if;
        set i = i + 1;
    end while;
    set foreign_key_checks = 1;
    call fill_seeds();
    commit;
end $$
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-08-11 19:41:08
