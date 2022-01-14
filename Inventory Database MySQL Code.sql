-- Table Creation

create table Assettype (type varchar(20) PRIMARY KEY);


create table Location (locationid int auto_increment PRIMARY KEY, room numeric(3,0) NOT NULL, floor numeric(1,0) NOT NULL);


create table Vendor (vendorid int auto_increment PRIMARY KEY, vendorname varchar(30) NOT NULL, addressnumber numeric(8,0), streetname varchar(30) NOT NULL, state char(2) NOT NULL);


create table Department (departmentid int auto_increment PRIMARY KEY, name varchar(30), locationid int, CONSTRAINT departmentlocationfk FOREIGN KEY (locationid) REFERENCES Location(locationid));


create table Purchaseorder (purchaseorderid int auto_increment PRIMARY KEY, invoicenumber varchar(10) NOT NULL, invoicedate datetime(3) NOT NULL, vendorid int, CONSTRAINT vendoridfk FOREIGN KEY (vendorid) REFERENCES Vendor(vendorid), amount numeric(8,2) NOT NULL);


create table Asset (assetid int auto_increment PRIMARY KEY, description varchar(50) NOT NULL, cost numeric(8,2) NOT NULL, estimatedlife numeric(2,0) NOT NULL, purchaseorderid int, CONSTRAINT purchaseorderfk FOREIGN KEY (purchaseorderid) REFERENCES Purchaseorder(purchaseorderid), type varchar(20), CONSTRAINT typefk FOREIGN KEY (type) REFERENCES Assettype(type), departmentid int, CONSTRAINT departmentfk FOREIGN KEY (departmentid) REFERENCES Department(departmentid));


insert into Assettype (type)
	values ('projector'),
	('laptop'),
	('projector control'),
	('printer'),
	('touch screen tv'),
	('desktop computer'),
	('monitor')

insert into Location (room, floor)
	values (101,1),
	(102,1),
	(103,1),
	(201,2),
	(202,2),
	(203,2),
	(301,3),
	(302,3),
	(303,3)

insert into Vendor (vendorname, addressnumber, streetname, state)
	values ('Office Depot',17560,'White Marsh Avenue','MD'),
	('Dell',515,'Spring Lane','CA'),
	('Lenova',725,'Springfield Boulevard','MI'),
	('Amazon',720,'Sunshine Road','WA'),
	('Visual Sound',720,'Sunshine Road','WA')

insert into Department (name, locationid)
	values ('Accounting',1),
	('Finance',2),
	('Marketing',3),
	('Sales',4),
	('IT Help Desk',5),
	('Business Intelligence',6),
	('Networking',7),
	('Tax',8),
	('Budget',9)

insert into Purchaseorder (invoicenumber, invoicedate, vendorid, amount)
	values ('0000006780','2020-07-08T14:11:25',2,578.20),
	('0000005520','2020-09-02T13:13:25',5,3520.75),
	('0000004530','2021-01-01T08:11:25',5,1531.20),
	('0000002250','2020-08-05T09:15:25',1,862.20)

insert into Asset (description, cost, estimatedlife, purchaseorderid, type, departmentid)
	values ('Optiplex 5050'578.20,5,1,6,1),
	('Crestron 550',3520.75,5,2,3,4),
	('Sony A7000',1531.20,5,3,1,4),
	('MSI 550',862.20,5,4,2,2)

Bulk insert Asset
From 'C:UsersUserDocumentsAIT735AIT 735 Bulk Upload for Assets.csv'
With
(
Rowterminator = 'n',
Fieldterminator = ','
)
	


Alter table Asset
Add Check (cost >= 0)

Alter table Asset
Add Check (estimatedlife > 0)

Alter table Location
Add Check (room > 0)

Alter table Location
Add Check (floor >= 0)

Alter table Purchaseorder
Add Check (invoicedate > '1910-01-01T00:00:00' AND invoicedate < NOW(3))

Alter table Purchaseorder
Add Check (amount >= 0)

-- Requirement 1

-- Variables


delimiter //

create procedure asset_add
(p_description varchar(50), p_cost numeric(8,2), p_estimatedlife numeric(2,0), p_purchaseorderid int, p_type varchar(20), p_departmentid int)
sp_lbl:

begin




	if not exists (select 1 from Purchaseorder where p_purchaseorderid = purchaseorderid)
	then
		/* print 'Purchaseorder does not exist' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;
	
	

	if exists (select 1 from Asset where upper(p_description) + CAST(p_purchaseorderid AS char) = upper(description) + Cast(purchaseorderid as char))
	then
		/* print 'Asset already exists' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;

	

	if not exists (select 1 from Department where p_departmentid = departmentid)
	then
		/* print 'Department does not exist' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;

	

	if not exists (select 1 from Assettype where upper(p_type) = upper(type))
	then
		/* print 'Asset type does not exist' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;
	


	start transaction;
		insert into Asset (description, cost, estimatedlife, purchaseorderid, type, departmentid) values
		(p_description, p_cost, p_estimatedlife, p_purchaseorderid, p_type, p_departmentid);
		
		if @@error <> 0
			then
				rollback;
				/* print 'Failed Insertion' */
				leave sp_lbl;
			end if;

		/* print 'Asset added' */

	commit ;
end;
//

delimiter ;



-- Requirement 2

-- Variables


delimiter //

create procedure asset_updatecost
(p_assetid int, p_cost numeric(6,2))
sp_lbl:

begin



	

	if not exists (select 1 from Asset where  p_assetid = assetid)
		then
			/* print 'Incorrect Asset Id' */
			/* print 'Failed Update' */
			leave sp_lbl;
		end if;

	

	start transaction;
		update Asset
		set cost = p_cost where assetid = p_assetid;

		if @@error <> 0
			then
				rollback;
				/* print 'Update Failed' */
				leave sp_lbl;
			end if;
		/* print 'Update is Successful' */

	commit ;
end;
//

delimiter ;



-- Requirement 3

-- Variables


delimiter //

create procedure asset_display
(p_assetid int)
sp_lbl:

begin




	if not exists (select 1 from Asset where  p_assetid = assetid)
		then
			/* print 'Incorrect asset Id' */
			/* print 'Failed Display' */
			leave sp_lbl;
		end if;

	

	start transaction;

		select p_assetid as assetid, description, cost, estimatedlife, purchaseorderid, departmentid
		from Asset where p_assetid = assetid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;





-- Requirement 4

-- Variables


delimiter //

create procedure asset_delete
(p_assetid int)
sp_lbl:

begin


	

	if not exists (select 1 from Asset where  p_assetid = assetid)
		then
			/* print 'Incorrect asset Id' */
			/* print 'Failed Deletion' */
			leave sp_lbl;
		end if;



	start transaction;
		delete from Asset where p_assetid = assetid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Deletion' */
				leave sp_lbl;
			end if;

		/* print 'Deletion is Successful' */

	commit ;
end;
//

delimiter ;


-- Requirement 5

-- Variables

delimiter //

create procedure location_add
(p_room numeric(3,0), p_floor numeric(2,0))
sp_lbl:

begin






	if exists (select 1 from Location where p_room + p_floor = room + floor)
	then
		/* print 'Location already exists' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;
	



	start transaction;
		insert into Location values
		(p_room, p_floor);
		
		if @@error <> 0
			then
				rollback;
				/* print 'Failed Insertion' */
				leave sp_lbl;
			end if;

		/* print 'Location added' */

	commit ;
end;
//

delimiter ;





-- Requirement 6

-- Variables


delimiter //

create procedure location_update
(p_locationid int, p_room numeric(3,0), p_floor numeric(2,0))
sp_lbl:

begin



	

	if not exists (select 1 from Location where  p_locationid = locationid)
		then
			/* print 'Incorrect Location Id' */
			/* print 'Failed Update' */
			leave sp_lbl;
		end if;



	start transaction;
		update Location
		set room = p_room, floor = p_floor where locationid = p_locationid;

		if @@error <> 0
			then
				rollback;
				/* print 'Update Failed' */
				leave sp_lbl;
			end if;
		/* print 'Update is Successful' */

	commit ;
end;
//

delimiter ;




-- Requirement 7

-- Variables


delimiter //

create procedure location_delete
(p_locationid int)
sp_lbl:

begin




	if not exists (select 1 from Location where  p_locationid = locationid)
		then
			/* print 'Incorrect Location Id' */
			/* print 'Failed Deletion' */
			leave sp_lbl;
		end if;

	start transaction;
		delete from Location where p_locationid = locationid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Deletion' */
				leave sp_lbl;
			end if;

		/* print 'Deletion is Successful' */

	commit ;
end;
//

delimiter ;




-- Requirement 8

-- Variables


delimiter //

create procedure vendor_add
(p_vendorname varchar(30), p_addressnumber numeric(8,0), p_streetname varchar(30), p_state char(2))
sp_lbl:

begin



	


	if exists (select 1 from Vendor where upper(p_vendorname) + Cast(p_addressnumber AS char) + upper(p_streetname) + upper(p_state) = upper(vendorname) + Cast(addressnumber as char) + upper(streetname) + upper(state))
	then
		/* print 'Vendor already exists' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;
	



	start transaction;
		insert into Vendor values
		(p_vendorname, p_addressnumber, p_streetname, p_state);
		
		if @@error <> 0
			then
				rollback;
				/* print 'Failed Insertion' */
				leave sp_lbl;
			end if;

		/* print 'Vendor added' */

	commit ;
end;
//

delimiter ;






-- Requirement 9

-- Variables


delimiter //

create procedure vendor_update
(p_vendorid int, p_addressnumber numeric(8,0), p_streetname varchar(30))
sp_lbl:

begin





	if not exists (select 1 from Vendor where  p_vendorid = vendorid)
		then
			/* print 'Incorrect Vendor Id' */
			/* print 'Failed Update' */
			leave sp_lbl;
		end if;



	start transaction;
		update Vendor
		set addressnumber = p_addressnumber, streetname = p_streetname where vendorid = p_vendorid;

		if @@error <> 0
			then
				rollback;
				/* print 'Update Failed' */
				leave sp_lbl;
			end if;
		/* print 'Update is Successful' */

	commit ;
end;
//

delimiter ;





-- Requirement 10

-- Variables


delimiter //

create procedure vendor_delete
(p_vendorid int)
sp_lbl:

begin


	

	if not exists (select 1 from Vendor where  p_vendorid = vendorid)
		then
			/* print 'Incorrect Vendor Id' */
			/* print 'Failed Deletion' */
			leave sp_lbl;
		end if;

	start transaction;
		delete from Vendor where p_vendorid = vendorid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Deletion' */
				leave sp_lbl;
			end if;

		/* print 'Deletion is Successful' */

	commit ;
end;
//

delimiter ;





-- Requirement 11

-- Variables


delimiter //

create procedure vendor_display
(p_vendorid int)
sp_lbl:

begin




	if not exists (select 1 from Vendor where  p_vendorid = vendorid)
		then
			/* print 'Incorrect Vendor Id' */
			/* print 'Failed Display' */
			leave sp_lbl;
		end if;

	start transaction;
	
		select p_vendorid as vendorid, vendorname, addressnumber, streetname
		from Vendor where p_vendorid = vendorid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;




-- Requirement 12

-- Variables


delimiter //

create procedure purchaseorder_add
(p_invoicenumber varchar(10), p_invoicedate datetime(3), p_vendorid int, p_amount numeric(7,2))
sp_lbl:

begin



	


	if not exists (select 1 from Vendor where p_vendorid = vendorid)
	then
		/* print 'Vendor does not exist' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;




	if exists (select 1 from Purchaseorder where p_invoicenumber = invoicenumber)
	then
		/* print 'Invoice already exists' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;




	if p_amount <> 0
	then
		/* print 'Amount needs to be zero' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;


	

	start transaction;
		insert into Purchaseorder values
		(p_invoicenumber, p_invoicedate, p_vendorid, p_amount);
		
		if @@error <> 0
			then
				rollback;
				/* print 'Failed Insertion' */
				leave sp_lbl;
			end if;

		/* print 'Purchaseorder added' */

	commit ;
end;
//

delimiter ;





-- Requirement 13

-- Variables


delimiter //

create procedure purchaseorder_display
(p_purchaseorderid int)
sp_lbl:

begin




	if not exists (select 1 from Purchaseorder where  p_purchaseorderid = purchaseorderid)
		then
			/* print 'Incorrect Purchaseorder Id' */
			/* print 'Failed Display' */
			leave sp_lbl;
		end if;

	start transaction;
	
		select p_purchaseorderid, Purchaseorder.invoicenumber, Purchaseorder.invoicedate, Purchaseorder.vendorid, Asset.assetid, Asset.description, Asset.cost
		from Purchaseorder 
		INNER JOIN Asset
		ON Purchaseorder.purchaseorderid = Asset.purchaseorderid
		where p_purchaseorderid = purchaseorderid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;






-- Requirement 14

-- Variables


delimiter //

create procedure type_add
(p_type varchar(20))
sp_lbl:

begin



	


	if exists (select 1 from Assettype where upper(p_type) = upper(type))
	then
		/* print 'Type already exists' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;
	

	

	start transaction;
		insert into Assettype values
		(p_type);
		
		if @@error <> 0
			then
				rollback;
				/* print 'Failed Insertion' */
				leave sp_lbl;
			end if;

		/* print 'Type added' */

	commit ;
end;
//

delimiter ;





-- Requirement 15


-- Variables


delimiter //

create procedure department_add
(p_name varchar(30), p_locationid int)
sp_lbl:

begin



	


	if not exists (select 1 from Location where p_locationid = locationid)
	then
		/* print 'Location does not exist' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;





	if exists (select 1 from Department where upper(p_name) = upper(name))
	then
		/* print 'Department already exists' */
		/* print 'Failed Insertion' */
		leave sp_lbl;
	end if;
	



	start transaction;
		insert into Department values
		(p_name, p_locationid);
		
		if @@error <> 0
			then
				rollback;
				/* print 'Failed Insertion' */
				leave sp_lbl;
			end if;



	commit ;
end;
//

delimiter ;





-- Requirement 16

-- Variables


delimiter //

create procedure department_delete
(p_departmentid int)
sp_lbl:

begin




	if not exists (select 1 from Department where  p_departmentid = departmentid)
		then
			/* print 'Incorrect Department Id' */
			/* print 'Failed Deletion' */
			leave sp_lbl;
		end if;

	start transaction;
		delete from Department where p_departmentid = departmentid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Deletion' */
				leave sp_lbl;
			end if;

		/* print 'Deletion is Successful' */

	commit ;
end;
//

delimiter ;





-- Requirement 17

-- Variables


delimiter //

create procedure department_update
(p_departmentid int, p_name varchar(30))
sp_lbl:

begin





	if not exists (select 1 from Department where  p_departmentid = departmentid)
		then
			/* print 'Incorrect Department Id' */
			/* print 'Failed Update' */
			leave sp_lbl;
		end if;



	start transaction;
		update Department
		set name = p_name where departmentid = p_departmentid;

		if @@error <> 0
			then
				rollback;
				/* print 'Update Failed' */
				leave sp_lbl;
			end if;
		/* print 'Update is Successful' */

	commit ;
end;
//

delimiter ;

	



-- Requirement 18

-- Variables


delimiter //

create procedure department_display
(p_departmentid int)
sp_lbl:

begin


	

	if not exists (select 1 from Department where  p_departmentid = departmentid)
		then
			/* print 'Incorrect Department Id' */
			/* print 'Failed Display' */
			leave sp_lbl;
		end if;

	start transaction;
		
		select p_departmentid, Department.name, Department.locationid, Asset.description, Asset.cost
		from Department
		INNER JOIN Asset
		ON Department.departmentid = Asset.departmentid
		where p_departmentid = Department.departmentid;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;




-- Requirement 22

-- Variables


delimiter //

create procedure location_asset_display
(p_locationid int)
sp_lbl:

begin




	if not exists (select 1 from Location where  p_locationid = locationid)
		then
			/* print 'Incorrect Location Id' */
			/* print 'Failed Display' */
			leave sp_lbl;
		end if;

	start transaction;
		
		select p_locationid, Location.room, Location.floor, Asset.assetid, Asset.description, Asset.cost
		from Asset
		INNER JOIN Department
		ON Asset.departmentid = Department.departmentid
		INNER JOIN Location
		ON Department.locationid = Location.locationid
		where p_locationid = Location.locationid;		

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;





-- Requirement 23

-- Variable


delimiter //

create procedure identify_assetid
(p_paramdescription varchar(50))
sp_lbl:

begin



	start transaction;

		select assetid, description, cost
		from Asset
		where upper(description) like upper(CONCAT('%',p_paramdescription,'%'));



		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;





-- Requirement 24




create index vendor_state
on Vendor(state ASC);

-- Variable


delimiter //

create procedure vendor_state
(p_paramstate char(2))
sp_lbl:

begin



	start transaction;

		select vendorname, addressnumber, streetname, state
		from Vendor
		where state = p_paramstate;

		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;





-- Requirement 25

-- Variables


delimiter //

create procedure identify_purchaseorder
(p_paraminvoice varchar(10))
sp_lbl:

begin



	start transaction;
	
		select purchaseorderid, invoicenumber, invoicedate, amount
		from Purchaseorder
		where upper(invoicenumber) like upper(CONCAT('%',p_paraminvoice,'%'));



		if @@error <> 0
			then
				rollback;
				/* print 'Failed Display' */
				leave sp_lbl;
			end if;

		/* print 'Display is Successful' */

	commit ;
end;
//

delimiter ;

