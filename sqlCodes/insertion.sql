CREATE TABLE cities (  id int PRIMARY KEY AUTO_INCREMENT,  name varchar(255) not null );

CREATE TABLE workshops (  id int PRIMARY KEY AUTO_INCREMENT,  name varchar(255) not null,  total_slots int not null,  city_id int not null, foreign key(city_id) references cities(id) );

CREATE TABLE slots_availability (  workshop_id int not null,  date date not null,  available_slots int not null);

CREATE TABLE bookings (  id int PRIMARY KEY AUTO_INCREMENT,  workshop_id int not null,  user_id int not null,  booking_date date not null,  date_created datetime not null);

CREATE TABLE users (  id int PRIMARY KEY AUTO_INCREMENT,  name varchar(255) not null,  phone varchar(255) not null,  mail varchar(255) not null );

ALTER TABLE workshops ADD FOREIGN KEY (city_id) REFERENCES cities (id);

ALTER TABLE slots_availability ADD FOREIGN KEY (workshop_id) REFERENCES workshops (id);

ALTER TABLE bookings ADD FOREIGN KEY (workshop_id) REFERENCES workshops (id);

ALTER TABLE bookings ADD FOREIGN KEY (user_id) REFERENCES users (id);



insert into cities (name) values  ("Bangalore"), ("Delhi") , ("Guwahati") ;

insert into workshops (name, total_slots, city_id) values ("BLR-Workshop1", 4, 1); 

insert into workshops (name, total_slots, city_id) values ("BLR-Workshop2", 3, 1); 

insert into workshops (name, total_slots, city_id) values ("BLR-Workshop3", 3, 1); 

insert into workshops (name, total_slots, city_id) values ("GHY-Workshop1", 2, 2; 

insert into workshops (name, total_slots, city_id) values ("DLH-Workshop1", 7, 3); 

insert into workshops (name, total_slots, city_id) values ("GHY-Workshop2", 5, 2); 
insert into workshops (name, total_slots, city_id) values ("GHY-Workshop3", 4, 2); 
insert into workshops (name, total_slots, city_id) values ("DLH-Workshop2", 6, 3); 
insert into workshops (name, total_slots, city_id) values ("DLH-Workshop3", 3, 3); 
insert into workshops (name, total_slots, city_id) values ("DLH-Workshop4", 4, 3); 





insert into users (name, phone, mail) values ("Anurag", "1234", "abcd@gmail.com");

insert into users (name, phone, mail) values ("Zubayer", "2234", "bcd@gmail.com");

insert into users (name, phone, mail) values ("John", "3234", "dcd@gmail.com");

insert into users (name, phone, mail) values ("Harry", "6234", "dde@gmail.com");

insert into users (name, phone, mail) values ("Ron", "23234", "cde@gmail.com");

insert into users (name, phone, mail) values ("Jack", "73234", "fde@gmail.com");

insert into users (name, phone, mail) values ("Jake", "93234", "hde@gmail.com");
