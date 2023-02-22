BEGIN
		--truncate table [ODS].[dbo].[HTS_PartnerTracings]
		MERGE [ODS].[dbo].[HTS_PartnerTracings] AS a
			USING(SELECT DISTINCT a.ID, a.[FacilityName]
			  ,a.[SiteCode]
			  ,a.[PatientPk]
			  ,a.[HtsNumber]
			  ,a.[Emr]
			  ,a.[Project]
			  ,[TraceType]
			  ,[TraceDate]
			  ,[TraceOutcome]
			  ,[BookingDate] 
			  	 
		  FROM [HTSCentral].[dbo].[HtsPartnerTracings](NoLock) a
		  INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
		  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
		  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
			and a.SiteCode = b.SiteCode
			and a.TraceDate  = b.TraceDate 			
			and a.BookingDate  = b.BookingDate 
			and a.ID = b.ID

			)
	WHEN NOT MATCHED THEN 
		INSERT(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TraceType,TraceDate,TraceOutcome,BookingDate) 
		VALUES(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,TraceType,TraceDate,TraceOutcome,BookingDate)

	WHEN MATCHED THEN
		UPDATE SET 
			a.[FacilityName]=b.[FacilityName],
			
			a.[TraceType]	=b.[TraceType],
			a.[TraceDate]	=b.[TraceDate],
			a.[TraceOutcome]=b.[TraceOutcome],
			a.[BookingDate]	=b.[BookingDate];
END