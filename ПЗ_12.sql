use library413_bazyleva; #Bazyleva


DELIMITER $$
CREATE FUNCTION READ_DURATION_AND_STATUS (start_date DATE, finish_date DATE)
RETURNS VARCHAR (150) DETERMINISTIC
BEGIN
	DECLARE days INT;
	DECLARE message VARCHAR (150);
	SET days = DATEDIFF(finish_date, start_date);
	CASE
		WHEN (days<10) THEN SET message = 'ХОРОШО' ;
		WHEN ((days>=10) AND (days<=30)) THEN SET message = 'УВЕДОМЛЕНИЕ';
		WHEN (days>30) THEN SET message = 'ПРЕДУПРЕЖДЕНИЕ';
	END CASE;
	RETURN CONCAT(days, ' - ', message);
END$$
DELIMITER ; #Bazyleva


SELECT sb_id,
 sb_start, 
 sb_finish, 
 READ_DURATION_AND_STATUS (sb_start, sb_finish) AS rdns
FROM subscriptions
WHERE sb_is_active='Y'; #Bazyleva



create table books_statistics (
	total INTEGER UNSIGNED NOT NULL,
    given INTEGER UNSIGNED NOT NULL,
    rest INTEGER UNSIGNED NOT NULL); #Bazyleva
    
select * from books_statistics; #Bazyleva


INSERT INTO books_statistics (total, given, rest)
SELECT
	IFNULL (total, 0),
	IFNULL (given,0),
	IFNULL (total-given,0) AS rest
FROM (SELECT (SELECT SUM(b_quantity) FROM books) AS total,
			 (SELECT COUNT(sb_book) FROM subscriptions 
             WHERE sb_is_active = 'Y') AS given)
	AS prepared_data; #Bazyleva

select * from books_statistics; #Bazyleva    
    

drop trigger if exists upd_bks_sts_on_books_ins;
drop trigger if exists ipd_bks_sts_on_books_del;
drop trigger if exists upd_bks_sts_on_books_upd; #Bazyleva 

DELIMITER $$
CREATE TRIGGER upd_bks_sts_on_books_ins BEFORE INSERT ON books
FOR EACH ROW
	BEGIN
		UPDATE books_statistics 
		SET total = total + NEW.b_quantity,
			rest = total - given ;
	END;
$$ #Bazyleva 



-- Создание триггера, реагирующего на удаление книг:
DELIMITER $$
CREATE TRIGGER upd_bks_sts_on_books_del BEFORE DELETE ON books
FOR EACH ROW
	BEGIN
		UPDATE books_statistics 
        SET total = total - OLD.b_quantity,
			given = given - (SELECT COUNT(sb_book) FROM subscriptions
								WHERE sb_book = OLD.b_id 
                                AND sb_is_active='Y'),
			rest = total - given;
	END;
$$ #Bazyleva 


-- Создание триггера, реагирующего на изменение количества книг:
DELIMITER $$
CREATE TRIGGER upd_bks_sts_on_books_upd BEFORE UPDATE ON books
FOR EACH ROW
	BEGIN
		UPDATE books_statistics 
        SET total = total - OLD.b_quantity + NEW.b_quantity,
			rest = total - given ;
	END;
$$ #Bazyleva 


-- Создание триггера, реагирующего на добавление выдачи книг:
DELIMITER $$
CREATE TRIGGER upd_bks_sts_on_subscriptions_ins 
BEFORE INSERT 
ON subscriptions
FOR EACH ROW
	BEGIN
		SET @delta = 0;
		IF (NEW. sb_is_active ='Y') THEN
			SET @delta = 1;
		END IF;
		UPDATE books_statistics 
        SET rest = rest - @delta,
			given = given + @delta;
END;
$$ #Bazyleva 


-- Создание триггера, реагирующего на удаление выдачи книг:
DELIMITER $$
CREATE TRIGGER upd_bks_sts_on_subscriptions_del 
BEFORE DELETE 
ON subscriptions
FOR EACH ROW
	BEGIN
		SET @delta = 0;
		IF (OLD.sb_is_active = 'Y') THEN
			SET @delta = 1;
		END IF;
		UPDATE books_statistics 
        SET rest = rest + @delta,
			given = given - @delta;
END;
$$ #Bazyleva 


-- Создание триггера, реагирующего на обновление выдачи книг:
DELIMITER $$
CREATE TRIGGER upd_bks_sts_on_subscriptions_upd 
BEFORE UPDATE 
ON subscriptions
FOR EACH ROW
	BEGIN
		SET @delta = 0;
        
		IF ((NEW.sb_is_active = 'Y') AND (OLD.sb_is_active = 'N')) THEN
			SET @delta = -1;
		END IF;
        
		IF ((NEW.sb_is_active = 'N') AND (OLD.sb_is_active = 'Y')) THEN
			SET @delta = 1;
		END IF;
        
		UPDATE books_statistics 
        SET rest = rest + @delta,
			given = given - @delta;
END;
$$ #Bazyleva 




-- Проверка триггера upd_bks_sts_on_subscriptions_upd к таблице subscriptions
select * from books_statistics;

update subscriptions set sb_is_active="Y" where sb_id=1;
select * from books_statistics; #Bazyleva 


-- Проверка триггера upd_bks_sts_on_subscriptions_del  к таблице subscriptions
select * from books_statistics; #Bazyleva 

delete from subscriptions where sb_id=3;
select * from books_statistics; #Bazyleva 



-- Проверка триггера upd_bks_sts_on_subscriptions_ins  к таблице subscriptions

select * from books_statistics; #Bazyleva 

insert into subscriptions (sb_subscriber, sb_book, 
sb_start, sb_finish, sb_is_active)
values (1, 5, "2011-04-05", "2011-05-06", 'Y');
select * from books_statistics #Bazyleva 



-- Проверка триггера upd_bks_sts_on_books_ins  к таблице books
select * from books_statistics; #Bazyleva 

insert into books (b_name, b_year, b_quantity)
values ("Психология влияния", 2002, 4);
select * from books_statistics; #Bazyleva 



-- Проверка триггера upd_bks_sts_on_books_del  к таблице books
select * from books_statistics; #Bazyleva 

delete from books where b_name="Психология влияния";
select * from books_statistics; #Bazyleva 


-- Проверка триггера upd_bks_sts_on_books_upd  к таблице books
select * from books_statistics; #Bazyleva 

update books set b_quantity=4 where b_name="Евгений Онегин";
select * from books_statistics; #Bazyleva 




create table books_authors_statistics (
	ba_id INT NOT NULL AUTO_INCREMENT,
    name_authors VARCHAR(45) NOT NULL,
    count_books INT NOT NULL,
    PRIMARY KEY (ba_id)); #Bazyleva3_1

select * from books_authors_statistics; #Bazyleva3_1

-- Триггер для добавления записи о выдаче книги
DELIMITER $$
CREATE TRIGGER subscription_ins AFTER INSERT ON subscriptions
FOR EACH ROW
	BEGIN 
		DECLARE v_name_authors VARCHAR(45);
		SELECT a_name INTO v_name_authors FROM m2m_books_authors m
			JOIN authors a ON m.a_id = a.a_id
			WHERE m.b_id = NEW.sb_book
			LIMIT 1;
		IF EXISTS (select * from books_authors_statistics where name_authors=v_name_authors) THEN 
			UPDATE books_authors_statistics
			SET count_books = count_books + 1
			WHERE name_authors = v_name_authors;
		ELSE
			insert into books_authors_statistics (name_authors, count_books) 
            values (v_name_authors, 1);
		END IF;
	END;
$$ #Bazyleva3_1

insert into subscriptions(sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active)
values (4, 1, "2012-05-05", "2012-06-06", "Y");
select * from books_authors_statistics; #Bazyleva3_1


-- Триггер для удаления записи о выдаче книги
DELIMITER $$
CREATE TRIGGER subscription_del AFTER DELETE ON subscriptions
FOR EACH ROW
	BEGIN 
		DECLARE v_name_authors VARCHAR(45);
		SELECT a_name INTO v_name_authors FROM m2m_books_authors m
			JOIN authors a ON m.a_id = a.a_id
			WHERE m.b_id = OLD.sb_book
			LIMIT 1;
		 
		UPDATE books_authors_statistics
		SET count_books = count_books - 1
		WHERE name_authors = v_name_authors;
			
	END;
$$ #Bazyleva3_1

delete from subscriptions where sb_id=9;
select * from books_authors_statistics; #Bazyleva3_1



-- Триггер для изменения записи кода выданной книги
DELIMITER $$
CREATE TRIGGER subscription_upd AFTER UPDATE ON subscriptions
FOR EACH ROW
	BEGIN 
		DECLARE v_old_name_authors VARCHAR(45);
        DECLARE v_new_name_authors VARCHAR(45);
		SELECT a_name INTO v_old_name_authors FROM m2m_books_authors m
			JOIN authors a ON m.a_id = a.a_id
			WHERE m.b_id = OLD.sb_book
			LIMIT 1;
		SELECT a_name INTO v_new_name_authors FROM m2m_books_authors m
			JOIN authors a ON m.a_id = a.a_id
			WHERE m.b_id = NEW.sb_book
			LIMIT 1;
		IF v_old_name_authors != v_new_name_authors THEN 
			UPDATE books_authors_statistics
			SET count_books = count_books - 1
			WHERE name_authors = v_old_name_authors;
            
			UPDATE books_authors_statistics
			SET count_books = count_books + 1
			WHERE name_authors = v_new_name_authors;
		END IF;	
	END;
$$ #Bazyleva3_1


update subscriptions
set sb_book=1 where sb_id=3;
select * from books_authors_statistics; #Bazyleva3_1




create table archive (
	s_id INT NOT NULL,
    s_name VARCHAR(45) NOT NULL,
    sex CHAR(1) NOT NULL,
    birthday DATE NOT NULL,
    PRIMARY KEY (s_id)); #Bazyleva3_2
  
select * from archive; #Bazyleva3_2

DELIMITER //
CREATE TRIGGER del_subscriber BEFORE DELETE ON subscribers
FOR EACH ROW
BEGIN
	DECLARE v_s_id NUMERIC(6);
	declare v_s_name VARCHAR(45);
	declare v_sex CHAR(1);
	DECLARE v_birthday DATE ;
	
    SET v_s_id=Old.s_id;
    SET v_s_name=Old.s_name;
    SET v_sex=Old.sex;
    SET v_birthday=Old.birthday;
     
	insert into archive (s_id, s_name, sex, birthday)
    values (v_s_id, v_s_name, v_sex, v_birthday);
END// #Bazyleva3_2


delete from subscribers where s_id=2;
select * from archive;
select * from subscribers; #Bazyleva3_2


select * from archive; #Bazyleva3_3
select * from subscribers; #Bazyleva3_3

DELIMITER //
create procedure recover_subscriber(s_r_id INT)
	begin

		declare v_s_name VARCHAR(45);
		declare v_sex CHAR(1);
		DECLARE v_birthday DATE ;
	
		SET v_s_name=(select s_name from archive where s_id=s_r_id);
		SET v_sex=(select sex from archive where s_id=s_r_id);
		SET v_birthday=(select birthday from archive where s_id=s_r_id);
        
        insert into subscribers(s_id, s_name, sex, birthday)
        values (s_r_id, v_s_name, v_sex, v_birthday);
        
        delete from archive where s_id=s_r_id;
end// #Bazyleva3_3

call recover_subscriber(2);
select * from subscribers; #Bazyleva3_3

select * from archive; #Bazyleva3_3