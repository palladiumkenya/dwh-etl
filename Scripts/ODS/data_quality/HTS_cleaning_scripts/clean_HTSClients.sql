---------------------------------------------------HTS_clients----------------------------------------------------

------------------Update Dob to NULL  where dates are missing, where dates are > today and where dates are <1900 year--------------------

UPDATE ODS.[dbo].[HTS_clients] SET Dob = NULL where Dob < CAST ('1910-01-01' AS DATE)
GO

UPDATE ODS.[dbo].[HTS_clients] SET Dob = NULL where Dob > GETDATE()
Go

UPDATE ODS.[dbo].[HTS_clients] SET Dob = NULL where Dob is NULL
Go
 --------------------------Update Gender----------------------------------------------------
 UPDATE ODS.[dbo].[HTS_clients] SET Gender =  CASE 
            WHEN Gender = 'M' THEN 'Male'          
            WHEN Gender = 'F' THEN 'Female'    
                END
WHERE Gender in ('F','M')

Select 
Dob
from ODS.[dbo].[HTS_clients]