   truncate table [ods].[dbo].[all_EMRSites];

	MERGE [ods].[dbo].[all_EMRSites] AS a
	USING(SELECT DISTINCT MFL_Code,[Facility Name],County,SubCounty,[Owner],Latitude,Longitude,SDP,[SDP Agency],Implementation,EMR,[EMR Status],[HTS Use],[HTS Deployment],[HTS Status],[IL Status],[Registration IE],[Phamarmacy IE],mlab,Ushauri,Nishauri,[Appointment Management IE],OVC,OTZ,PrEP,[3PM],AIR,KP,MCH,TB,[Lab Manifest],Comments,Project
	FROM [HIS_Implementation].[dbo].[All_EMRSites] WHERE MFL_Code !='') AS b 
	ON(a.MFL_Code COLLATE SQL_Latin1_General_CP1_CI_AS =b.MFL_Code COLLATE SQL_Latin1_General_CP1_CI_AS)
    WHEN MATCHED THEN
    UPDATE SET 
    a.[Facility_Name] = B.[Facility Name]
	WHEN NOT MATCHED THEN 
	INSERT(MFL_Code,[Facility_Name],County,SubCounty,[Owner],Latitude,Longitude,SDP,[SDP_Agency],Implementation,EMR,[EMR_Status],[HTS_Use],[HTS_Deployment],[HTS_Status],[IL_Status],[Registration_IE],Phamarmacy_IE,mlab,Ushauri,Nishauri,[Appointment_Management_IE],OVC,OTZ,PrEP,[_3PM],AIR,KP,MCH,TB,Lab_Manifest,Comments,Project) 
	VALUES(MFL_Code,[Facility Name],County,SubCounty,[Owner],Latitude,Longitude,SDP,[SDP Agency],Implementation,EMR,[EMR Status],[HTS Use],[HTS Deployment],[HTS Status],[IL Status],[Registration IE],[Phamarmacy IE],mlab,Ushauri,Nishauri,[Appointment Management IE],OVC,OTZ,PrEP,[3PM],AIR,KP,MCH,TB,[Lab Manifest],Comments,Project);
