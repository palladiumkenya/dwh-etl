
with cte AS ( Select  
		P.PatientPID,           
		C.PatientId,           
		F.code,            
		C.created, ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code,C.VisitID
		ORDER BY c.created desc) Row_Num
        FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
		INNER JOIN [DWAPICentral].[dbo].[CovidExtract](NoLock) C  ON C.[PatientId]= P.ID AND C.Voided=0
		INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id  AND F.Voided=0       ) 

		delete c
        from     [DWAPICentral].[dbo].[CovidExtract](NoLock) C 
        inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON c.[PatientId]= P.ID AND c.Voided = 0        
		inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0        
		inner join cte on c.PatientId = cte.PatientId  
            and cte.Created = c.created 
            and cte.Code =  f.Code  
		where  Row_Num > 1


			