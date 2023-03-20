---------------Update Client Tested As ------------------------------------
 UPDATE ODS.[dbo].[HTS_ClientTests] SET ClientTestedAs =  CASE 
            WHEN ClientTestedAs  in ('C: Couple (includes polygamous)','Couple') THEN 'Couple'        
            WHEN ClientTestedAs in ('I: Individual','Individual')  THEN 'Individual'
           ELSE 'NULL'    
                END
Go 
------------------Update Entry Point----------------------------------------------

UPDATE M  SET  M.EntryPoint= T.target_name  
from [ODS].[DBO].[HTS_ClientTests] M 
INNER JOIN [ODS].[dbo].[lkp_patient_source] T  
ON M.EntryPoint = T.source_name
GO
