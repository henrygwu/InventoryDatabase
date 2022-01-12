#Table Creation

create table Assettype (type varchar(20) PRIMARY KEY);

create table Location (locationid int auto_increment PRIMARY KEY, room numeric(3,0) NOT NULL, floor numeric(1,0) NOT NULL);

create table Vendor (vendorid int auto_increment PRIMARY KEY, vendorname varchar(30) NOT NULL, addressnumber numeric(8,0), streetname varchar(30) NOT NULL, state char(2) NOT NULL);

create table Department (departmentid int auto_increment PRIMARY KEY, name varchar(30), locationid int, CONSTRAINT departmentlocationfk FOREIGN KEY (locationid) REFERENCES Location(locationid));

create table Purchaseorder (purchaseorderid int auto_increment PRIMARY KEY, invoicenumber varchar(10) NOT NULL, invoicedate datetime NOT NULL, vendorid int, CONSTRAINT vendoridfk FOREIGN KEY (vendorid) REFERENCES Vendor(vendorid), amount numeric(8,2) NOT NULL);

create table Asset (assetid int auto_increment PRIMARY KEY, description varchar(50) NOT NULL, cost numeric(8,2) NOT NULL, estimatedlife numeric(2,0) NOT NULL, purchaseorderid int, CONSTRAINT purchaseorderfk FOREIGN KEY (purchaseorderid) REFERENCES Purchaseorder(purchaseorderid), type varchar(20), CONSTRAINT typefk FOREIGN KEY (type) REFERENCES Assettype(type), departmentid int, CONSTRAINT departmentfk FOREIGN KEY (departmentid) REFERENCES Department(departmentid));


insert into Assettype (type)
	values ('projector'),
	('laptop'),
	('projector control'),
	('printer'),
	('touch screen tv'),
	('desktop computer'),
	('monitor');

insert into Location (room, floor)
	values (101,1),
	(102,1),
	(103,1),
	(201,2),
	(202,2),
	(203,2),
	(301,3),
	(302,3),
	(303,3);

insert into Vendor (vendorname, addressnumber, streetname, state)
	values ('Office Depot',17560,'White Marsh Avenue','MD'),
	('Dell',515,'Spring Lane','CA'),
	('Lenova',725,'Springfield Boulevard','MI'),
	('Amazon',720,'Sunshine Road','WA'),
	('Visual Sound',720,'Sunshine Road','WA');

insert into Department (name, locationid)
	values ('Accounting',1),
	('Finance',2),
	('Marketing',3),
	('Sales',4),
	('IT Help Desk',5),
	('Business Intelligence',6),
	('Networking',7),
	('Tax',8),
	('Budget',9);

insert into Purchaseorder (invoicenumber, invoicedate, vendorid, amount)
	values ('0000006780','2020-07-08T14:11:25',2,578.20),
	('0000005520','2020-09-02T13:13:25',5,3520.75),
	('0000004530','2021-01-01T08:11:25',5,1531.20),
	('0000002250','2020-08-05T09:15:25',1,862.20);

insert into Asset (description, cost, estimatedlife, purchaseorderid, type, departmentid)
	values ('Optiplex 5050',578.20,5,1,6,1),
	('Crestron 550',3520.75,5,2,3,4),
	('Sony A7000',1531.20,5,3,1,4),
	('MSI 550',862.20,5,4,2,2);


Alter table Asset
Add Check (cost >= 0);

Alter table Asset
Add Check (estimatedlife > 0);

Alter table Location
Add Check (room > 0);

Alter table Location
Add Check (floor >= 0);

Alter table Purchaseorder
Add Check (invoicedate > '1910-01-01T00:00:00' AND invoicedate < GETDATE());

Alter table Purchaseorder
Add Check (amount >= 0);
