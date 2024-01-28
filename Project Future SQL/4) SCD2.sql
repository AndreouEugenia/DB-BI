---------------------REMOVE RELATIOSHIPS-------------------------------------------------------------------------------------------------
USE ChinookDW;

ALTER TABLE FactInvoice DROP  constraint  FactInvoiceDimDate ;

ALTER TABLE FactInvoice DROP  constraint  FactInvoiceDimCustomer ;

ALTER TABLE FactInvoice DROP constraint  FactInvoiceDimTrack ;

ALTER TABLE DimPlaylistTrack DROP constraint  DimPlaylistTrackDimTrack ;

ALTER TABLE DimPlaylistTrack DROP constraint  DimPlaylistTrackDimPlaylist ; 


-------Δημιουργία νέου πίνακα σύγκρισης + ιστορικού (Staging_DimCustomerEmployee)στην DW------------------------------------------
USE ChinookStaging

DROP TABLE IF EXISTS Staging_DimCustomerEmployee;

CREATE TABLE Staging_DimCustomerEmployee
(
    DimCustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DimCustomerId INT NOT NULL,
    DimCustomerName NVARCHAR(MAX) NOT NULL,
	DimCustomerCompany NVARCHAR(MAX) NULL,
	DimCustomerAddress NVARCHAR(MAX) NULL, 
    DimCustomerCity NVARCHAR(MAX) NULL,
    DimCustomerState NVARCHAR(MAX) NULL,
    DimCustomerCountry NVARCHAR(MAX) NULL,
	DimCustomerPostalCode NVARCHAR(MAX) NULL, 
	DimCustomerPhone NVARCHAR(MAX) NULL,
	DimCustomerFax NVARCHAR(MAX) NULL,
	DimCustomerEmail NVARCHAR(MAX) NOT NULL,
	
	DimEmployeeId INT NOT NULL,
    DimEmployeeName NVARCHAR(MAX) NOT NULL,
    DimEmployeeTitle NVARCHAR(MAX) NULL,
	DimEmployeeReportsTo INT NULL,
	DimEmployeeBirthDate DATETIME NULL,
	DimEmployeeHireDate DATETIME NULL, 
	DimEmployeeAddress NVARCHAR(MAX) NULL,
	DimEmployeeCity NVARCHAR(MAX) NULL,
	DimEmployeeState NVARCHAR(MAX) NULL,
	DimEmployeeCountry NVARCHAR(MAX) NULL,
	DimEmployeePostalCode NVARCHAR(MAX) NULL,
	DimEmployeePhone NVARCHAR(MAX) NULL,
	DimEmployeeFax NVARCHAR(MAX) NULL,
	DimEmployeeEmail NVARCHAR(MAX) NULL,

    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2008-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '2014-01-01' NOT NULL,
    RowChangeReason NVARCHAR(MAX) NULL
);

select* from Staging_DimCustomerEmployee;

----------------------------------------------ALLAGES SE OLTP ----------------------------------------------------------------
USE CHINOOK;

------1) Αλλαγή διεύθυνσης σε Customer-------------------------------------------------------------------------------------------------

----Επαναφορά αλλαγής γραμμής εάν υπάρχει
USE Chinook;

UPDATE Customer 
SET 
City = 'Brussels'
WHERE CustomerId = 8;

select* from customer
where customerId=8;
--------------------------

UPDATE Customer 
SET 
City = 'Antwerp'
WHERE CustomerId = 8;

select*from customer;

------2) Νέος πελάτης -----------------------------------------------------------------------------------------------------------------
----Διαγραφή νεας γραμμής εάν υπάρχει
Use Chinook;
SELECT * FROM Customer;

DELETE FROM Customer
WHERE CustomerId = 60;
--------------------------

--Βρίσκουμε τον τελευταίο αριθμό ID
DECLARE @NewId INT;
SET @NewId = (SELECT MAX(CustomerId) + 1 FROM Customer);

-- Εισάγουμε τη νέα εγγραφή με τον επόμενο αριθμό ID
INSERT INTO Customer 
(	CustomerId , 
	FirstName , 
	LastName , 
	[Address] , 
	City ,
	[State],
	Country , 
	PostalCode , 
	Phone ,
	Email , 
	SupportRepId )
VALUES 
(
	@NewId, 	
	'Maria',
	'MeTaKitrina',
	'Thiseos 49',
	'Athens',
	'kalithea',
	'Greece',
	'11111',
	'6988111111',
	'maria@gmail.com',
	3
);
Select* from customer;


---------------------------------------------------------------SCD2------------------------------------------------------------------
USE ChinookStaging;
-----Insert νεα δεδομένα σε CustomerEmployee πίνακα Staging, που θα διαθέτει μόνο τα ενημερωμένα δεδομένα------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE CustomerEmployee;

INSERT INTO CustomerEmployee 
( 
	CustomerId,
	CustomerFirstName,
	CustomerLastName,
	CustomerCompany,
	CustomerAddress,
	CustomerCity,
	CustomerState,
	CustomerCountry,
	CustomerPostalCode,
	CustomerPhone,
	CustomerFax,
	CustomerEmail,

	EmployeeId,
	EmployeeLastName,
	EmployeeFirstName,
	EmployeeTitle,
	EmployeeReportsTo,
	EmployeeBirthDate,
	EmployeeHireDate,
	EmployeeAddress,
	EmployeeCity,
	EmployeeState,
	EmployeeCountry,
	EmployeePostalCode,
	EmployeePhone,
	EmployeeFax,
	EmployeeEmail
)
select
	CustomerId,
	Customer.FirstName,
	Customer.LastName,
	Customer.Company,
	Customer.Address,
	Customer.City,
	Customer.State,
	Customer.Country,
	Customer.PostalCode,
	Customer.Phone,
	Customer.Fax,
	Customer.Email,

	EmployeeId,
	Employee.LastName,
	Employee.FirstName,
	Employee.Title,
	Employee.ReportsTo,
	Employee.BirthDate,
	Employee.HireDate,
	Employee.Address,
	Employee.City,
	Employee.State,
	Employee.Country,
	Employee.PostalCode,
	Employee.Phone,
	Employee.Fax,
	Employee.Email

from Chinook.dbo.Customer
inner join Chinook.dbo.Employee
on Chinook.dbo.Customer.SupportRepId = Chinook.dbo.Employee. EmployeeId 
order by CustomerId asc;

select*from CustomerEmployee;

----Εισαγωγή των νέων values σε Πίνακα Σύγκρισης--------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Staging_DimCustomerEmployee
	( 
	DimCustomerId,
	DimCustomerName,
	DimCustomerCompany,
	DimCustomerAddress,
	DimCustomerCity,
	DimCustomerState,
	DimCustomerCountry,
	DimCustomerPostalCode,
	DimCustomerPhone,
	DimCustomerFax,
	DimCustomerEmail,

	DimEmployeeId,
	DimEmployeeName,
	DimEmployeeTitle,
	DimEmployeeReportsTo,
	DimEmployeeBirthDate,
	DimEmployeeHireDate,
	DimEmployeeAddress,
	DimEmployeeCity,
	DimEmployeeState,
	DimEmployeeCountry,
	DimEmployeePostalCode,
	DimEmployeePhone,
	DimEmployeeFax,
	DimEmployeeEmail
)
select

	CustomerId,
	CustomerFirstName+' '+CustomerLastName,
	CustomerCompany,
	CustomerAddress,
	CustomerCity,
	CustomerState,
	CustomerCountry,
	CustomerPostalCode,
	CustomerPhone,
	CustomerFax,
	CustomerEmail,

    EmployeeId,
	EmployeeFirstName+' '+EmployeeLastName,
	EmployeeTitle,
	EmployeeReportsTo,
	EmployeeBirthDate,
	EmployeeHireDate,
	EmployeeAddress,
	EmployeeCity,
	EmployeeState,
	EmployeeCountry,
	EmployeePostalCode,
	EmployeePhone,
	EmployeeFax,
	EmployeeEmail
	
	FROM ChinookStaging.dbo.CustomerEmployee
	;

select* from Staging_DimCustomerEmployee;

--------Incremental Loading σε DW----------------------------------
use ChinookDW;

declare @etldate date = '2014-12-06';

INSERT INTO  ChinookDW.dbo.DimCustomerEmployee 
(
	DimCustomerId,
	DimCustomerName,
	DimCustomerCompany,
	DimCustomerAddress,
	DimCustomerCity,
	DimCustomerState,
	DimCustomerCountry,
	DimCustomerPhone,
	DimCustomerFax,
	DimCustomerEmail,

	DimEmployeeId,
	DimEmployeeName,
	DimEmployeeTitle,
	DimEmployeeReportsTo,
	DimEmployeeBirthDate,
	DimEmployeeHireDate,
	DimEmployeeAddress,
	DimEmployeeCity,
	DimEmployeeState,
	DimEmployeeCountry,
	DimEmployeePhone,
	DimEmployeeFax,
	DimEmployeeEmail,
	
    RowStartDate,
    RowChangeReason
	)
SELECT 

	DimCustomerId,
	DimCustomerName,
	DimCustomerCompany,
	DimCustomerAddress,
	DimCustomerCity,
	DimCustomerState,
	DimCustomerCountry,
	DimCustomerPhone,
	DimCustomerFax,
	DimCustomerEmail,

	DimEmployeeId,
	DimEmployeeName,
	DimEmployeeTitle,
	DimEmployeeReportsTo,
	DimEmployeeBirthDate,
	DimEmployeeHireDate,
	DimEmployeeAddress,
	DimEmployeeCity,
	DimEmployeeState,
	DimEmployeeCountry,
	DimEmployeePhone,
	DimEmployeeFax,
	DimEmployeeEmail,

	@etldate ,
	ActionName
	   
FROM
	(
	MERGE 
		 ChinookDW . dbo .DimCustomerEmployee AS target
		USING  ChinookStaging . dbo .Staging_DimCustomerEmployee as source
			ON target.DimCustomerId  = source.DimCustomerId 

----Αν δεν βρεί αλλαγή---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 WHEN MATCHED AND 
	 source.DimCustomerCity <> target.DimCustomerCity  
	 AND target. RowIsCurrent  = 1 
	 THEN UPDATE SET
		 target.RowIsCurrent = 0,
		 target.RowEndDate = dateadd(day, -1, @etldate
		 ) ,
		 target.RowChangeReason = 'UPDATED NOT CURRENT'

----Αλλαγή στοιχείων πελάτη------------------------------------------------------------------------------------------------------------------------------------------
	 WHEN NOT MATCHED THEN
	   INSERT  
    (
	DimCustomerId,
	DimCustomerName,
	DimCustomerCompany,
	DimCustomerAddress,
	DimCustomerCity,
	DimCustomerState,
	DimCustomerCountry,
	DimCustomerPhone,
	DimCustomerFax,
	DimCustomerEmail,

	DimEmployeeId,
	DimEmployeeName,
	DimEmployeeTitle,
	DimEmployeeReportsTo,
	DimEmployeeBirthDate,
	DimEmployeeHireDate,
	DimEmployeeAddress,
	DimEmployeeCity,
	DimEmployeeState,
	DimEmployeeCountry,
	DimEmployeePhone,
	DimEmployeeFax,
	DimEmployeeEmail,
    
	RowStartDate,
    RowChangeReason
	)
	   VALUES
		(
		source.DimCustomerID, 
		source.DimCustomerName, 
		source.DimCustomerCompany,
		source.DimCustomerAddress,
		source.DimCustomerCity, 
		source.DimCustomerState, 
		source.DimCustomerCountry,
		source.DimCustomerPhone,
		source.DimCustomerFax,
		source.DimCustomerEmail,

		source.DimEmployeeId,
		source.DimEmployeeName,
		source.DimEmployeeTitle,
		source.DimEmployeeReportsTo,
		source.DimEmployeeBirthDate,
		source.DimEmployeeHireDate,
		source.DimEmployeeAddress,
		source.DimEmployeeCity,
		source.DimEmployeeState,
		source.DimEmployeeCountry,
		source.DimEmployeePhone,
		source.DimEmployeeFax,
		source.DimEmployeeEmail,

		CAST(@etldate AS Date),
		'NEW RECORD'
		)

---------Διαγραφή πελάτη--------------------------------------------------------------------------------
	WHEN NOT MATCHED BY Source THEN
		UPDATE SET 
			Target.RowEndDate= dateadd(day, -1, @etldate),
			target.RowIsCurrent = 0,
			Target.RowChangeReason  = 'SOFT DELETE'
	OUTPUT 
		source.DimCustomerID, 
		source.DimCustomerName, 
		source.DimCustomerCompany,
		source.DimCustomerAddress,
		source.DimCustomerCity, 
		source.DimCustomerState, 
		source.DimCustomerCountry,
		source.DimCustomerPhone,
		source.DimCustomerFax,
		source.DimCustomerEmail,

		source.DimEmployeeId,
		source.DimEmployeeName,
		source.DimEmployeeTitle,
		source.DimEmployeeReportsTo,
		source.DimEmployeeBirthDate,
		source.DimEmployeeHireDate,
		source.DimEmployeeAddress,
		source.DimEmployeeCity,
		source.DimEmployeeState,
		source.DimEmployeeCountry,
		source.DimEmployeePhone,
		source.DimEmployeeFax,
		source.DimEmployeeEmail,

		$Action as ActionName
)	
AS Mrg
WHERE Mrg.ActionName='UPDATE'
AND  DimCustomerId  IS NOT NULL;

Select*from DimCustomerEmployee;

---------------------------------------Add constraints again
USE ChinookDW

ALTER TABLE FactInvoice ADD  constraint  FactInvoiceDimDate  FOREIGN KEY (OrderDateKey)
    REFERENCES DimDate(DateKey);

ALTER TABLE FactInvoice ADD  constraint  FactInvoiceDimCustomer   FOREIGN KEY (FactCustomerKey)
    REFERENCES DimCustomerEmployee (DimCustomerKey);

ALTER TABLE FactInvoice ADD constraint  FactInvoiceDimTrack  FOREIGN KEY (FactTrackKey)
    REFERENCES DimTrack (DimTrackKey);

ALTER TABLE DimPlaylistTrack ADD constraint  DimPlaylistTrackDimTrack  FOREIGN KEY (DimPlaylistTrackTrackId)
	REFERENCES DimTrack(DimTrackKey);

ALTER TABLE DimPlaylistTrack ADD constraint  DimPlaylistTrackDimPlaylist  FOREIGN KEY (DimPlaylistTrackPlaylistId)
	REFERENCES DimPlaylist (DimPlaylistKey);


-------
Use ChinookDW;
select* from DimCustomerEmployee;