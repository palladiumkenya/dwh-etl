--MSSQL - Backup to Disk with Encryption

--1. Create a Database Master Key of the master database:

-- Creates a database master key.   
-- The key is encrypted using the password "<master key password>"  
USE master;  
GO  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P@lladium@1';  
GO 


--2. Create a Backup Certificate:

Use Master  
GO  
CREATE CERTIFICATE ODSDBBackupEncryptCert  
   WITH SUBJECT = 'ODS Backup Encryption Certificate';                              
GO 
CREATE CERTIFICATE NDWHDBBackupEncryptCert  
   WITH SUBJECT = 'NDWH Backup Encryption Certificate';                              
GO 
CREATE CERTIFICATE HIS_ImplementationDBBackupEncryptCert  
   WITH SUBJECT = 'HIS_Implementation Backup Encryption Certificate';                              
GO
CREATE CERTIFICATE SSISErrorHandlingDBBackupEncryptCert  
   WITH SUBJECT = 'SSISErrorHandling Backup Encryption Certificate';                              
GO

--3. Backup the database: Don't run this unless you want to do a backup

BACKUP DATABASE ODS  
TO DISK = N'C:\Backup\ODS.bak'  
WITH  
  COMPRESSION,  
  ENCRYPTION   
   (  
   ALGORITHM = AES_256,  
   SERVER CERTIFICATE = ODSDBBackupEncryptCert  
   ),  
  STATS = 10  
GO
BACKUP DATABASE NDWH  
TO DISK = N'C:\Backup\NDWH.bak'  
WITH  
  COMPRESSION,  
  ENCRYPTION   
   (  
   ALGORITHM = AES_256,  
   SERVER CERTIFICATE = NDWHDBBackupEncryptCert  
   ),  
  STATS = 10  
GO
BACKUP DATABASE HIS_Implementation  
TO DISK = N'C:\Backup\HIS_Implementation.bak'  
WITH  
  COMPRESSION,  
  ENCRYPTION   
   (  
   ALGORITHM = AES_256,  
   SERVER CERTIFICATE = HIS_ImplementationDBBackupEncryptCert  
   ),  
  STATS = 10  
GO
BACKUP DATABASE SSISErrorHandling  
TO DISK = N'C:\Backup\SSISErrorHandling.bak'  
WITH  
  COMPRESSION,  
  ENCRYPTION   
   (  
   ALGORITHM = AES_256,  
   SERVER CERTIFICATE = SSISErrorHandlingDBBackupEncryptCert  
   ),  
  STATS = 10  
GO