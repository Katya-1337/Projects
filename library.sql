create database library413_bazyleva;
use library413_bazyleva; #Bazyleva

CREATE TABLE books
(
	b_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	b_name VARCHAR(150) NOT NULL,
	b_year SMALLINT UNSIGNED NOT NULL,
	b_quantity SMALLINT UNSIGNED NOT NULL,
	CONSTRAINT PK_books PRIMARY KEY (b_id)
)
; #Bazyleva
CREATE TABLE subscribers
(
	s_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	s_name VARCHAR(150) NOT NULL,
	CONSTRAINT K_subscribers PRIMARY KEY (s_id)
)
; #Bazyleva
CREATE TABLE subscriptions
(
	sb_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	sb_subscriber INTEGER UNSIGNED NOT NULL,
	sb_book INTEGER UNSIGNED NOT NULL,
	sb_start DATE NOT NULL,
	sb_finish DATE NOT NULL,
	sb_is_active ENUM ('Y', 'N') NOT NULL,
	CONSTRAINT PK_subscriptions PRIMARY KEY (sb_id)
)
; #Bazyleva

ALTER TABLE subscriptions 
 ADD CONSTRAINT FK_subscriptions_books
	FOREIGN KEY (sb_book) REFERENCES books (b_id) ON DELETE Cascade ON UPDATE Cascade
;
ALTER TABLE subscriptions 
 ADD CONSTRAINT FK_subscriptions_subscribers
	FOREIGN KEY (sb_subscriber) REFERENCES subscribers (s_id) ON DELETE Cascade ON UPDATE Cascade;
#Bazyleva

create table genres
(
g_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
g_name VARCHAR(150) NOT NULL,
CONSTRAINT PK_genres PRIMARY KEY (g_id)
);#Bazyleva
create table authors
(
a_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
a_name VARCHAR(150) NOT NULL,
CONSTRAINT PK_authors PRIMARY KEY (a_id)
);#Bazyleva
create table m2m_books_authors
(
b_id integer unsigned not null,
a_id integer unsigned not null
);#Bazyleva
create table m2m_books_genres
(
b_id integer unsigned not null,
g_id integer unsigned not null
);#Bazyleva

ALTER TABLE m2m_books_genres
 ADD CONSTRAINT FK_m2m_books_genres_books
	FOREIGN KEY (b_id) REFERENCES books (b_id) ON DELETE Cascade ON UPDATE Cascade; #Bazyleva
ALTER TABLE m2m_books_genres
 ADD CONSTRAINT FK_m2m_books_genres_genres
	FOREIGN KEY (g_id) REFERENCES genres (g_id) ON DELETE Cascade ON UPDATE Cascade; #Bazyleva

ALTER TABLE m2m_books_authors
 ADD CONSTRAINT FK_m2m_books_authors_books
	FOREIGN KEY (b_id) REFERENCES books (b_id) ON DELETE Cascade ON UPDATE Cascade; #Bazyleva
ALTER TABLE m2m_books_authors
 ADD CONSTRAINT FK_m2m_books_authors_authors
	FOREIGN KEY (a_id) REFERENCES authors (a_id) ON DELETE Cascade ON UPDATE Cascade; #Bazyleva

ALTER TABLE subscribers 
MODIFY birthday DATE NOT NULL DEFAULT '2000-01-01';
ALTER TABLE subscribers 
MODIFY sex char(1) not null DEFAULT 'м'; #Bazyleva


ALTER TABLE subscribers add constraint check_birthday check(
	'2024' - year(birthday) >= 12); #Bazyleva
ALTER TABLE subscribers add constraint check_sex check(
	sex like "м" or sex like "ж"); #Bazyleva
    
insert into books (b_name, b_year, b_quantity) values ('Евгений Онегин', 1985, 2); #Bazyleva
insert into books (b_name, b_year, b_quantity) values ('Сказка о рыбаке и рыбке', 1990, 3);
insert into books (b_name, b_year, b_quantity) values ('Основание и империя', 2000, 5);
insert into books (b_name, b_year, b_quantity) values ('Психология программирования', 1998, 1); #Bazyleva
insert into books (b_name, b_year, b_quantity) values ('Язык программирования C++', 1996, 3);
insert into books (b_name, b_year, b_quantity) values ('Курс теоритической физики', 1981, 12);
insert into books (b_name, b_year, b_quantity) values ('Искусство программирования', 1993, 7); #Bazyleva

select * from books; #Bazyleva

insert into authors (a_name) values ('А.Кирилов'); #Bazyleva
insert into authors (a_name) values ('А. Супругов');
insert into authors (a_name) values ('Д. Кингсбери');
insert into authors (a_name) values ('Л.Д. Самбер'); #Bazyleva
insert into authors (a_name) values ('Е.М. Лифштиц');
insert into authors (a_name) values ('Б. Констаун');
insert into authors (a_name) values ('А.С. Савёлов'); #Bazyleva

select * from authors; #Bazyleva

insert into genres (g_name) values ('Сдём'); #Bazyleva
insert into genres (g_name) values ('Кирилицу');
insert into genres (g_name) values ('Мат анализ');
insert into genres (g_name) values ('Синквейн'); #Bazyleva
insert into genres (g_name) values ('Саморез');
insert into genres (g_name) values ('Наука'); #Bazyleva

select * from genres; #Bazyleva

insert into subscribers (s_name) values ('Сидоров И.И.');
insert into subscribers (s_name) values ('Курчатов П.П.'); #Bazyleva
insert into subscribers (s_name) values ('Алегров С.С.');
insert into subscribers (s_name) values ('Саранский А.С.');

select * from subscribers; #Bazyleva

insert into m2m_books_authors (b_id, a_id) values (1, 7);
insert into m2m_books_authors (b_id, a_id) values (2, 7); #Bazyleva
insert into m2m_books_authors (b_id, a_id) values (3, 2);
insert into m2m_books_authors (b_id, a_id) values (4, 3);
insert into m2m_books_authors (b_id, a_id) values (4, 6);
insert into m2m_books_authors (b_id, a_id) values (5, 6); #Bazyleva
insert into m2m_books_authors (b_id, a_id) values (6, 5);
insert into m2m_books_authors (b_id, a_id) values (6, 4);
insert into m2m_books_authors (b_id, a_id) values (7, 1); #Bazyleva

select * from m2m_books_authors; #Bazyleva

insert into m2m_books_genres (b_id, g_id) values (1, 1); #Bazyleva
insert into m2m_books_genres (b_id, g_id) values (1, 5);
insert into m2m_books_genres (b_id, g_id) values (2, 1);
insert into m2m_books_genres (b_id, g_id) values (2, 5);
insert into m2m_books_genres (b_id, g_id) values (3, 6); #Bazyleva
insert into m2m_books_genres (b_id, g_id) values (4, 2);
insert into m2m_books_genres (b_id, g_id) values (4, 3);
insert into m2m_books_genres (b_id, g_id) values (5, 2);
insert into m2m_books_genres (b_id, g_id) values (6, 5);
insert into m2m_books_genres (b_id, g_id) values (7, 2); #Bazyleva
insert into m2m_books_genres (b_id, g_id) values (7, 5);

select * from m2m_books_genres; #Bazyleva


insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (1, 3, '2011-01-12', '2011-02-12', 'N');
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (1, 1, '2011-01-12', '2011-02-12', 'N');
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (3, 3, '2012-05-17', '2012-07-17', 'Y'); #Bazyleva
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (1, 2, '2012-06-11', '2012-08-11', 'N');
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (4, 5, '2012-06-11', '2012-08-11', 'N');
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (1, 7, '2014-08-03', '2014-10-03', 'N'); #Bazyleva
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (3, 5, '2014-08-03', '2014-10-03', 'Y');
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (3, 1, '2014-08-03', '2014-09-03', 'Y'); #Bazyleva
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (4, 1, '2015-03-07', '2015-10-07', 'Y');
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (1, 4, '2015-10-07', '2015-11-07', 'N');
insert into subscriptions (sb_subscriber, sb_book, sb_start, sb_finish, sb_is_active) 
values (4, 4, '2015-10-08', '2025-11-08', 'Y'); #Bazyleva

select * from subscriptions; #Bazyleva

create view bibl_fond as select b_name, a_name, g_name from books
join m2m_books_authors on books.b_id = m2m_books_authors.b_id
join authors on m2m_books_authors.a_id = authors.a_id	
join m2m_books_genres on books.b_id = m2m_books_genres.b_id
join genres on m2m_books_genres.g_id = genres.g_id; #Bazyleva

select * from bibl_fond; #Bazyleva

CREATE VIEW reader_books AS
SELECT b.b_name AS book_name, sb.sb_subscriber, s.s_name, sb.sb_start, sb.sb_finish AS subscriber_name
FROM subscriptions sb
JOIN books b ON sb.sb_book = b.b_id
JOIN subscribers s ON sb.sb_subscriber = s.s_id; #Bazyleva

select * from reader_books; #Bazyleva

create view genres_authors as 
SELECT a.a_name, g.g_name
FROM authors a
JOIN m2m_books_authors m ON a.a_id = m.a_id
JOIN m2m_books_genres mg ON m.b_id = mg.b_id
JOIN genres g ON mg.g_id = g.g_id; #Bazyleva

select * from genres_authors; #Bazyleva


