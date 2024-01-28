--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------STAGIND-------------------------------------------------------------------------------------------------------------

----ƒÁÏÈÔıÒ„ﬂ· ChinookStaging database-------------------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ChinookStaging')
BEGIN
    DROP DATABASE ChinookStaging;
END

CREATE DATABASE ChinookStaging;
GO

--------------------------------------- Customer-Employee-----------------------------------------------------------------------------------------------------------------
USE ChinookStaging;

DROP TABLE IF EXISTS ChinookStaging.dbo.CustomerEmployee ;

select 
	Customer.CustomerId AS CustomerId,
	Customer.FirstName AS CustomerFirstName,
	Customer.LastName AS CustomerLastName,
	Customer.Company AS CustomerCompany,
	Customer. Address  AS CustomerAddress,
	Customer.City AS CustomerCity ,
	Customer. State  AS CustomerState,
	Customer.Country AS CustomerCountry,
	Customer.PostalCode AS CustomerPostalCode,
	Customer.Phone AS CustomerPhone,
	Customer.Fax AS CustomerFax,
	Customer.Email AS CustomerEmail,

	Employee.EmployeeId AS EmployeeId,
	Employee.LastName AS EmployeeLastName,
	Employee.FirstName AS EmployeeFirstName,
	Employee.Title AS EmployeeTitle,
	Employee.ReportsTo AS EmployeeReportsTo,
	Employee.BirthDate AS EmployeeBirthDate,
	Employee.HireDate AS EmployeeHireDate,
	Employee. Address  AS EmployeeAddress,
	Employee.City AS EmployeeCity,
	Employee. State  AS EmployeeState,
	Employee.Country AS EmployeeCountry,
	Employee.PostalCode AS EmployeePostalCode,
	Employee.Phone AS EmployeePhone,
	Employee.Fax AS EmployeeFax,
	Employee.Email AS EmployeeEmail

into ChinookStaging.dbo.CustomerEmployee

from Chinook.dbo.Employee
inner join Chinook.dbo.Customer
on Chinook.dbo.Customer.SupportRepId = Chinook.dbo.Employee.EmployeeId

order by CustomerId asc;

Select* from  ChinookStaging.dbo.CustomerEmployee

--------------------------------------- Track-----------------------------------------------------------------------------------------------------------------------------------------
USE ChinookStaging;

DROP TABLE IF EXISTS ChinookStaging.dbo.Track ;

SELECT
	Track.TrackId AS TrackId,
	Track. Name  AS TrackName,
	Track.Composer AS TrackComposer,

	Album.AlbumId AS TrackAlbumId,
	Album.Title AS TrackAlbumTitle,

	Artist.ArtistId AS TrackArtistId,
	Artist. Name  AS TrackArtistName,

	Genre.GenreId AS TrackGenreId,
	Genre. Name  AS TrackGenreName,

	Track.Milliseconds AS TrackMilliseconds,
	Track.Bytes AS TrackBytes,
	Track.UnitPrice AS TrackUnitPrice,

	MediaType.MediaTypeId AS TrackMediaTypeId,
	MediaType. Name  AS TrackMediaTypeName

	INTO ChinookStaging.dbo.Track
FROM 
	Chinook.dbo.Track

INNER JOIN Chinook.dbo.Album
	ON Chinook.dbo.Track.AlbumId = Chinook.dbo.Album.AlbumId

INNER JOIN Chinook.dbo.Artist
	ON  Chinook.dbo.Artist.ArtistId = Chinook.dbo.Album.ArtistId

INNER JOIN Chinook.dbo.Genre
	ON Chinook.dbo.Genre.GenreId=Chinook.dbo.Track.GenreId

INNER JOIN Chinook.dbo.MediaType
	ON Chinook.dbo.Track.MediaTypeId=Chinook.dbo.MediaType.MediaTypeId

GROUP BY
	TrackId,
	Track.[Name], 
	Album.AlbumId,
	Album.Title,
	Genre.GenreId,
	Genre.[Name], 
	Artist.ArtistId,
	Artist.[Name], 
	Track.Composer,
	Track.UnitPrice,
	Track.Milliseconds,
	Track.Bytes,
	MediaType.MediaTypeId,
	Mediatype.[Name]

ORDER BY Chinook.dbo.Track.TrackId;

select* from Track;

---------------------------------------PlaylistTrack-------------------------------------------------------------------------------------------------------------------------------------
USE ChinookStaging;

DROP TABLE IF EXISTS ChinookStaging.dbo.PlaylistTrack ;

Select
    PlaylistTrack.PlaylistId AS PlaylistId,
    PlaylistTrack.TrackId AS PlaylistTrackId

into ChinookStaging.dbo.PlaylistTrack

from Chinook.dbo.PlaylistTrack;

select* from PlaylistTrack;

---------------------------------------Playlist------------------------------------------------------------------------------------------------------------------------------------------
USE ChinookStaging;

DROP TABLE IF EXISTS ChinookStaging.dbo.Playlist ;

Select
	Playlist.PlaylistId AS PlaylistId,
    Playlist.[Name] AS PlaylistName

into ChinookStaging.dbo.Playlist

from Chinook.dbo.Playlist;

select* from Playlist;

---------------------------------------Invoice-------------------------------------------------------------------------------------------------------------------------------------------
USE ChinookStaging;

DROP TABLE IF EXISTS ChinookStaging.dbo.Invoice ;

Select 
	Invoice.InvoiceId AS InvoiceId,
	InvoiceLine.InvoiceLineId AS InvoiceLineId,
	InvoiceLine.UnitPrice AS InvoiceUnitPrice,
	InvoiceLine.TrackId AS InvoiceTrackId,
	InvoiceLine.Quantity AS InvoiceQuantity,
	Invoice.CustomerId AS InvoiceCustomerId,
	Invoice.InvoiceDate As Orderdate,
	Invoice.BillingAddress AS InvoiceBillingAddress,
	Invoice.BillingCity AS InvoiceBillingCity,
	Invoice.BillingState AS InvoiceBillingState,
	Invoice.BillingCountry AS InvoiceBillingCountry,
	Invoice.BillingPostalCode AS InvoicePostalcode,
	Invoice.Total AS InvoiceTotal

INTO ChinookStaging.dbo.Invoice

FROM Chinook.dbo.Invoice 
INNER JOIN Chinook.dbo.InvoiceLine
ON Chinook.dbo.Invoice.InvoiceId= Chinook.dbo.InvoiceLine.InvoiceId;

select*from  ChinookStaging.dbo.Invoice;

------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------ƒ«Ã…œ’—√…¡ CHINOOKDW DB------------------------------------------------------------
USE master;
ALTER DATABASE ChinookDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ChinookDW')
BEGIN
    DROP DATABASE ChinookDW;
END

CREATE DATABASE ChinookDW
GO

------- DimCustomerEmployee --------------------------------------------------------------------------------------------------------------------
USE ChinookDW;

DROP TABLE IF EXISTS ChinookDW.dbo.DimCustomerEmployee;

CREATE TABLE DimCustomerEmployee 
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
    RowEndDate DATE DEFAULT '2014-12-31' NOT NULL,
    RowChangeReason NVARCHAR(MAX) NULL
);

 select*from DimCustomerEmployee;

----------- DimTracks ------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE ChinookDW;

DROP TABLE IF EXISTS ChinookDW.dbo.DimTrack;

CREATE TABLE DimTrack
(
    DimTrackKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DimTrackId INT NOT NULL,
    DimTrackName NVARCHAR(MAX) NOT NULL,
	DimTrackComposer NVARCHAR(MAX) NULL,
	DimTrackAlbumId INT NULL,
	DimTrackAlbumTitle NVARCHAR(MAX) NULL,
	DimTrackArtistId NVARCHAR(MAX) NULL,
	DimTrackArtistName NVARCHAR(MAX) NULL,
	DimTrackGenreId INT NULL,
	DimTrackGerneName NVARCHAR(MAX) NULL,
	DimTrackMilliseconds INT NOT NULL,
	DimTrackBytes INT NULL,
	DimTrackUnitPrice NUMERIC(10,2) NOT NULL,
	DimTrackMediaTypeId INT NOT NULL,
	DimTrackMediaTypeName NVARCHAR(MAX) NULL,

    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2008-12-31' NOT NULL,
    RowEndDate DATE DEFAULT '2014-12-31' NOT NULL,
    RowChangeReason NVARCHAR(MAX) NULL
);

select* from DimTrack;

----DimPlaylistTrack-------------------------------------------------------------------------------------------------------------------
USE ChinookDW

DROP TABLE IF EXISTS ChinookDW.dbo.DimPlaylistTrack;

CREATE TABLE DimPlaylistTrack
    (	
    	DimPlaylistTrackPlaylistId INT NOT NULL,
    	DimPlaylistTrackTrackId INT NOT NULL
    );

select* from DimPlaylistTrack;

----DimPlaylist-------------------------------------------------------------------------------------------------------------------
USE ChinookDW;

DROP TABLE IF EXISTS ChinookDW.dbo.DimPlaylist;

CREATE TABLE DimPlaylist
    (	
		DimPlaylistKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    	DimPlaylistId INT NOT NULL,
    	DimPlaylistName NVARCHAR(MAX) NULL,
		
		RowIsCurrent INT DEFAULT 1 NOT NULL,
		RowStartDate DATE DEFAULT '2008-12-31' NOT NULL,
		RowEndDate DATE DEFAULT '2014-12-31' NOT NULL,
		RowChangeReason NVARCHAR(MAX) NULL
    );

select* from DimPlaylist;

-------FactInvoice-------------------------------------------------------------------------------------------------------------------
USE ChinookDW

DROP TABLE IF EXISTS ChinookDW.dbo.FactInvoice;

CREATE TABLE FactInvoice
(
    FactTrackKey INT NOT NULL,
    FactCustomerKey INT NOT NULL,
	OrderDateKey INT NOT NULL,
	FactInvoiceUnitPrice NUMERIC(10,2) NULL, 
	FactQuantity INT NOT NULL,
	FactInvoiceId INT NOT NULL,
	FactInvoiceLineId INT NOT NULL,
	FactInvoiceBillingAddress VARCHAR(MAX) NULL,
	FactInvoiceBillingCity VARCHAR(MAX) NULL,
	FactInvoiceBillingState VARCHAR(MAX) NULL,
	FactInvoiceBillingCountry VARCHAR(MAX) NULL,
	FactInvoicePostalcode VARCHAR(MAX) NULL,
	FactInvoiceTotal NUMERIC(10,2) NOT NULL,
);

select*from FactInvoice;

-------------------------------------------------------- √≈Ã…”Ã¡ DW----------------------------------------------------
USE ChinookDW

----DimCustomerEmployee
----H Address+PostalCode „Ò‹ˆÙÁÍ·Ì ˘Ú ÏÈ· ÛÙﬁÎÁ Address
USE ChinookDW

TRUNCATE TABLE DimCustomerEmployee;

INSERT INTO DimCustomerEmployee 
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
	DimEmployeeEmail
)
SELECT
	CustomerId,
	CustomerFirstName+' '+CustomerLastName,
	CustomerCompany,
	CustomerAddress+' '+CustomerPostalCode,
	CustomerCity,
	CustomerState,
	CustomerCountry,
	CustomerPhone,
	CustomerFax,
	CustomerEmail,

	EmployeeId,
	EmployeeFirstName+' '+EmployeeLastName,
	EmployeeTitle,
	EmployeeReportsTo,
	EmployeeBirthDate,
	EmployeeHireDate,
	EmployeeAddress+' '+EmployeePostalCode,
	EmployeeCity,
	EmployeeState,
	EmployeeCountry,
	EmployeePhone,
	EmployeeFax,
	EmployeeEmail

FROM ChinookStaging.dbo.CustomerEmployee
;

Select * from DimCustomerEmployee;

----DimTrack-----------------------------------------------------------------------------------------------
USE ChinookDW

TRUNCATE TABLE DimTrack;

INSERT INTO DimTrack 
(
	DimTrackId,
	DimTrackName,
	DimTrackComposer,
	DimTrackAlbumId,
	DimTrackAlbumTitle,
	DimTrackArtistId,
	DimTrackArtistName,
	DimTrackGenreId,
	DimTrackGerneName,
	DimTrackMilliseconds,
	DimTrackBytes,
	DimTrackUnitPrice,
	DimTrackMediaTypeId,
	DimTrackMediaTypeName
)
SELECT  
	TrackId,
	TrackName,
	TrackComposer,
	TrackAlbumId,
	TrackAlbumTitle,
	TrackArtistId,
	TrackArtistName,
	TrackGenreId,
	TrackGenreName,
	TrackMilliseconds,
	TrackBytes,
	TrackUnitPrice,
	TrackMediaTypeId,
	TrackMediaTypeName

FROM ChinookStaging.dbo.Track

ORDER BY TrackId ASC;

Select * From DimTrack;

----DimPlaylist--------------------------------------------------------------------------------------------
USE ChinookDW

TRUNCATE TABLE DimPlaylistTrack;

INSERT INTO DimPlaylistTrack 
    (
    	DimPlaylistTrackPlaylistId,
    	DimPlaylistTrackTrackId
     )
SELECT 
     	PlaylistId,
     	PlaylistTrackId
FROM ChinookStaging.dbo.PlaylistTrack;

select* from DimPlaylistTrack;

----DimPlaylist--------------------------------------------------------------------------------------------
USE ChinookDW

TRUNCATE TABLE DimPlaylist;

INSERT INTO DimPlaylist 
    (
    	DimPlaylistId,
    	DimPlaylistName
     )
SELECT 
     	PlaylistId,
     	PlaylistName
FROM ChinookStaging.dbo.Playlist;

select* from DimPlaylist;

----FactInvoice----------------------------------------------------------------------------------------------
USE ChinookDW

TRUNCATE TABLE FactInvoice;

INSERT INTO FactInvoice 
( 
	FactTrackKey,
	FactCustomerKey,
	OrderDateKey,
	FactInvoiceId,
	FactInvoiceLineId,
	FactQuantity,
	FactInvoiceUnitPrice,
	FactInvoiceBillingAddress,
	FactInvoiceBillingCity,
	FactInvoiceBillingState,
	FactInvoiceBillingCountry,
	FactInvoiceTotal
)
SELECT 
	DimTrackKey,
	DimCustomerKey,
	CAST(FORMAT(OrderDate,'yyyyMMdd') AS INT),

	InvoiceId,
	InvoiceLineId,
	InvoiceQuantity,
	InvoiceUnitPrice,
	InvoiceBillingAddress+' '+InvoicePostalcode,
	InvoiceBillingCity,
	InvoiceBillingState,
	InvoiceBillingCountry,
	InvoiceTotal

FROM ChinookStaging.dbo.Invoice AS SI

INNER JOIN ChinookDW.dbo.DimTrack AS DWT
ON DWT.DimTrackId=SI.InvoiceTrackId

INNER JOIN ChinookDW.dbo.DimCustomerEmployee AS DWI
ON DWI.DimCustomerId = SI.InvoiceCustomerId;


select* from FactInvoice Order By FactTrackKey;






