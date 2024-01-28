--------------------------------------------- RELATIONSHIPS---------------------------------------------------------------------------------
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

