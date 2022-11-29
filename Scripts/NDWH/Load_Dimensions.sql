
BEGIN
	MERGE [NDWH].[dbo].[DimFacility] AS a
	USING(SELECT DISTINCT MFL_Code,[Facility Name],County,SubCounty,[owner],SDP,[SDP Agency],Implementation,EMR,[EMR Status],[HTS Use],[Project]
	FROM [ODS].[dbo].[All_EMRSites] WHERE MFL_Code !='') AS b 
	ON(a.FacilityCode =b.MFL_Code)
	--WHEN MATCHED THEN
 --   UPDATE SET 
 --   a.FacilityName = B.[Facility Name]
	WHEN NOT MATCHED THEN 
	INSERT(FacilityCode,FacilityName,County,District,owner,SDP,[SDP_Agency],Implementation,EMR,[EMR Status],[HTS Use],[Project]) 
	VALUES(MFL_Code,[Facility Name],County,SubCounty,[owner],SDP,[SDP Agency],Implementation,EMR,[EMR Status],[HTS Use],[Project]);
	;

	with cte AS (
		Select
		FacilityCode,
		 ROW_NUMBER() OVER (PARTITION BY FacilityCode ORDER BY
		 FacilityCode ) Row_Num
		FROM [NDWH].[dbo].[DimFacility]
		)
		delete from cte 
		Where Row_Num >1;

	UPDATE [NDWH].[dbo].[DimFacility] SET  		  
		SDPKey = b.PartnerKey
	FROM [NDWH].[dbo].[DimFacility]   a 
	LEFT OUTER JOIN [NDWH].[dbo].[DimPartner] b ON   a.SDP = b.PartnerName;
	--UPDATE [NDWH].[dbo].[DimFacility] 
	--SET Open24HoursKey =CASE
	--                        WHEN Open24Hours

	-----[NDWH].[dbo].[DimMaritalStatus]

	  	MERGE [NDWH].[dbo].[DimMaritalStatus] AS a
	USING(SELECT DISTINCT Target_MaritalStatus,Target_MaritalStatus AS maritalstatusDescription FROM  [ODS].[dbo].[lkp_MaritalStatus]) AS b 
	ON(a.[maritalstatusID]=b.Target_MaritalStatus)
	WHEN MATCHED THEN
    UPDATE SET 
    a.MaritalStatusDesription = B.[maritalstatusDescription]
	WHEN NOT MATCHED THEN 
	INSERT([maritalstatusID],MaritalStatusDesription) VALUES(Target_MaritalStatus,maritalstatusDescription);
	--populate DimPatientSource
	--truncate table [NDWH].[dbo].[DimPatientSource]

	MERGE [NDWH].[dbo].[DimPatient] AS a
	USING(SELECT DISTINCT [PatientPK],[PatientID],[PatientID] as PatientName,[SiteCode],[FacilityName],[Gender],[MaritalStatus]
					  ,[RegistrationDate],[RegistrationAtCCC],[RegistrationAtPMTCT],[DOB]
					  ,[RegistrationAtTBClinic],[Region],[District],[Village],[ContactRelation],[LastVisit],[EducationLevel]
					  ,[DateConfirmedHIVPositive],[PreviousARTExposure],[PreviousARTStartDate],[PatientSource]
					  ,[Emr],[Project],[Ident],[DateImported],[PKV],[PatientUID],[RegistrationYear]
					  ,[MPIPKV],[Orphan],[Inschool],[PatientType],[PopulationType],[KeyPopulationType],[PatientResidentCounty]
					  ,[PatientResidentSubCounty],[PatientResidentLocation],[PatientResidentSubLocation],[PatientResidentWard]
					  ,[TransferInDate],[Occupation]
				 FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Patients] WHERE SiteCode >0
				 
) AS b 
	ON( a.PatientPK = b.PatientPK AND a.siteCode = b.SiteCode)
	WHEN MATCHED THEN
    UPDATE SET 
    a.[PatientName] = B.[PatientName]
	WHEN NOT MATCHED THEN 
	INSERT([PatientPK],[PatientID],PatientName,[SiteCode],[FacilityName],[Gender],[MaritalStatus]
					  ,[RegistrationDate],[RegistrationAtCCC],[RegistrationAtPMTCT],[DOB]
					  ,[RegistrationAtTBClinic],[Region],[District],[Village],[ContactRelation],[LastVisit],[EducationLevel]
					  ,[DateConfirmedHIVPositive],[PreviousARTExposure],[PreviousARTStartDate],[PatientSource]
					  ,[Emr],[Project],[Ident],[DateImported],[PKV],[PatientUID],[RegistrationYear]
					  ,[MPIPKV],[Orphan],[Inschool],[PatientType],[PopulationType],[KeyPopulationType],[PatientResidentCounty]
					  ,[PatientResidentSubCounty],[PatientResidentLocation],[PatientResidentSubLocation],[PatientResidentWard]
					  ,[TransferInDate],[Occupation]) 
	VALUES([PatientPK],[PatientID],PatientName,[SiteCode],[FacilityName],[Gender],[MaritalStatus]
			,[RegistrationDate],[RegistrationAtCCC],[RegistrationAtPMTCT],[DOB]
			,[RegistrationAtTBClinic],[Region],[District],[Village],[ContactRelation],[LastVisit],[EducationLevel]
			,[DateConfirmedHIVPositive],[PreviousARTExposure],[PreviousARTStartDate],[PatientSource]
			,[Emr],[Project],[Ident],[DateImported],[PKV],[PatientUID],[RegistrationYear]
			,[MPIPKV],[Orphan],[Inschool],[PatientType],[PopulationType],[KeyPopulationType],[PatientResidentCounty]
			,[PatientResidentSubCounty],[PatientResidentLocation],[PatientResidentSubLocation],[PatientResidentWard]
			,[TransferInDate],[Occupation]);

	UPDATE [NDWH].[dbo].[DimPatient]
	SET [PatientID] = RTRIM(LTRIM([PatientID])),PatientPK= RTRIM(LTRIM(PatientPK)),SiteCode=RTRIM(LTRIM(SiteCode));

	------------------------------------CleanUp
	
	UPDATE [NDWH].[dbo].[DimPatient]
	SET GenderID = 'F'
	WHERE Gender LIKE '%FEMALE%';

	UPDATE [NDWH].[dbo].[DimPatient]
	SET GenderID = 'M'
	WHERE Gender LIKE '%MALE%';

	UPDATE a
		SET MaritalStatus_Clean = MaritalStatus
	FROM [NDWH].[dbo].[DimPatient] a;

	UPDATE a
		SET MaritalStatus_Clean = 'null'
	FROM [NDWH].[dbo].[DimPatient] a
	where MaritalStatus_Clean is null;

	UPDATE M 
		SET MaritalStatus_Clean = T.Target_MaritalStatus
	FROM [NDWH].[dbo].[DimPatient] M
	INNER JOIN [ODS].[dbo].[lkp_MaritalStatus] T
	on M.MaritalStatus_Clean = T.Source_MaritalStatus;


	UPDATE [NDWH].[dbo].[DimPatient] SET  
		  FacilityKey = c.FacilityKey,
		  GenderKey = e.GenderKey,
		  MaritalStatusKey = d.MaritalStatusKey,
		  [DateKey]=b.DateKey,
		  RegionKey = f.RegionKey,
		  VillageKey = g.VillageKey,
		  PatientSourceKey = h.PatientSourceKey,
		  PatientTypeKey = i.PatientTypeKey,
		  PopulationTypeKey = j.PopulationTypeKey

	FROM [NDWH].[dbo].[DimPatient]   a 
	LEFT OUTER JOIN [NDWH].[dbo].[DimDate] b ON   a.[RegistrationDate]=b.[DateAlternateKey]
	LEFT OUTER JOIN [NDWH].[dbo].[DimFacility] c ON a.SiteCode = c.FacilityCode
	LEFT OUTER JOIN [NDWH].[dbo].[DimMaritalStatus] d ON a.MaritalStatus_Clean = d.MaritalStatusID
	LEFT OUTER JOIN [NDWH].[dbo].[DimGender] e on a.Gender = e.GenderID
	LEFT OUTER JOIN [NDWH].[dbo].[DimRegion] f on a.Region = f.RegionID
	LEFT OUTER JOIN [NDWH].[dbo].[DimVillage] g on a.Village = g.VillageID
	LEFT OUTER JOIN [NDWH].[dbo].[DimPatientSource] h on a.PatientSource = h.PatientSourceID
	LEFT OUTER JOIN [NDWH].[dbo].[DimPatientType] i on a.PatientType = i.PatientTypeID
	LEFT OUTER JOIN [NDWH].[dbo].[DimPopulationType] j on a.PopulationType = j.PopulationTypeID
	;

	With CTE as   
		(  
		Select [PatientID],PatientPK,SiteCode,row_number() over (partition by [PatientID],PatientPK,SiteCode order by [PatientID],PatientPK) as dump_ from [NDWH].[dbo].[DimPatient]
		)  
		--Select * from CTE order by ClientID,ClientName
		--Select *  from CTE where dump_ =0
		delete  from CTE where dump_>1

	UPDATE [NDWH].[dbo].[DimPatient]
	SET MaritalStatusKey = 10
	WHERE MaritalStatusKey is null

	UPDATE [NDWH].[dbo].[DimPatient]
		SET Age = DATEDIFF(YEAR,DOB,GETDATE());

	UPDATE [NDWH].[dbo].[DimPatient]
	SET AgeBandKey=CASE
	                     WHEN [Age] < 1 THEN 1
	                     WHEN [Age] >=1 and [Age]<= 9 THEN 2
						 WHEN [Age] > 9 and [Age] <=14 THEN 3
						 WHEN [Age] >14  and [Age] <=19 THEN 4
						 WHEN [Age] >19  and [Age] <=24 THEN 5
						 WHEN [Age] >24  and [Age] <=29 THEN 6
						 WHEN [Age] >29  and [Age] <=34 THEN 7
						 WHEN [Age] >34  and [Age] <=39 THEN 8
						 WHEN [Age] >39  and [Age] <=44 THEN 9
						 WHEN [Age] >44  and [Age] <=49 THEN 10
						 WHEN [Age] >49  and [Age] <=54 THEN 11
						 WHEN [Age] >54  and [Age] <=59 THEN 12
						 WHEN [Age] >59  and [Age] <=64 THEN 13
						 WHEN [Age] >64  and [Age] <=69 THEN 14
						 WHEN [Age] >=70 THEN 15
						 ELSE 16
						 END;
	delete from [NDWH].[dbo].[DimPatient] where FacilityKey is null;
	------------------------------------End
	-----------------Remove duplicate
	
		--With CTE as   
		--(  
		--Select [PatientID],PatientPK,SiteCode,row_number() over (partition by [PatientID],PatientPK,SiteCode order by [PatientID],PatientPK) as dump_ from [NDWH].[dbo].[DimPatient]
		--)  
		----Select * from CTE order by ClientID,ClientName
		--Select *  from CTE where dump_ =0
		---delete  from CTE where dump_>1

	---------End

	-----DimCovidPatient
	MERGE [NDWH].[dbo].[DimCovidPatient] AS a
	USING(SELECT DISTINCT [PatientID],[PatientID] AS PatientName FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Covid]) AS b 
	ON(a.CovidPatientID=b.[PatientID])
	WHEN MATCHED THEN
    UPDATE SET 
    a.[CovidPatientName] = B.[PatientName]
	WHEN NOT MATCHED THEN 
	INSERT(CovidPatientID,[CovidPatientName]) VALUES([PatientID],PatientName);


	-----[NDWH].[dbo].[DimRegimen]
	----Truncate table [NDWH].[dbo].[DimRegimen]
	MERGE [NDWH].[dbo].[DimRegimen] AS a
	USING(SELECT DISTINCT StartRegimen,StartRegimen AS Regimen FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_ARTPatients]) AS b 
	ON(a.[RegimenID]=b.StartRegimen)
	WHEN MATCHED THEN
    UPDATE SET 
    a.[Regimen] = B.StartRegimen
	WHEN NOT MATCHED THEN 
	INSERT([RegimenID],[Regimen]) VALUES(StartRegimen,Regimen);

	UPDATE [NDWH].[dbo].[DimRegimen]
	SET [RegimenID] = 'UNCLASSIFIED',[Regimen]= 'UNCLASSIFIED'
	WHERE [RegimenID] IS NULL OR [RegimenID] = '' OR [RegimenID] =NULL
 


	MERGE [NDWH].[dbo].[DimPatientSource] AS a
	USING(SELECT DISTINCT PatientSource,PatientSource as PatientSourceName  FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Patients]) AS b 
	ON(a.PatientSourceID =b.PatientSource)
	WHEN MATCHED THEN
    UPDATE SET 
    a.PatientSourceName = B.PatientSourceName
	WHEN NOT MATCHED THEN 
	INSERT(PatientSourceID,PatientSourceName) VALUES(PatientSource,PatientSourceName);

	UPDATE  [NDWH].[dbo].[DimPatientSource]
	SET PatientSourceID = UPPER(PatientSourceID),
	    PatientSourceName = UPPER(PatientSourceName)

	--populate DimPartner
	---truncate table [NDWH].[dbo].[DimPartner]
	MERGE [NDWH].[dbo].[DimPartnerAndAgencyBridge] AS a
	USING(SELECT DISTINCT Implementing_Mechanism_Name,Implementing_Mechanism_Name as partnerName,County,Agency  FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[lkp_usgPartnerMenchanism]) AS b 
	ON(a.partnerID =b.partnerName)
	--WHEN MATCHED THEN
 --   UPDATE SET 
 --   a.partnerName = B.partnerName
	WHEN NOT MATCHED THEN 
	INSERT(partnerID,partnerName,CountyName,AgencyName) VALUES(Implementing_Mechanism_Name,partnerName,County,Agency);

	UPDATE  [NDWH].[dbo].[DimPartnerAndAgencyBridge]
		SET partnerID = UPPER(partnerID),
	    partnerName = UPPER(partnerName);

	--populate DimPartner
	---truncate table [NDWH].[dbo].[DimPartner]
	MERGE [NDWH].[dbo].[DimPartner] AS a
	USING(SELECT DISTINCT Implementing_Mechanism_Name,Implementing_Mechanism_Name as partnerName,Agency  FROM [All_Staging_2016_2]..lkp_usgPartnerMenchanism) AS b 
	ON(a.partnerID =b.partnerName)
	WHEN MATCHED THEN
    UPDATE SET 
    a.partnerName = B.partnerName
	WHEN NOT MATCHED THEN 
	INSERT(partnerID,partnerName,AgencyName) VALUES(Implementing_Mechanism_Name,partnerName,Agency);

	UPDATE  [NDWH].[dbo].[DimPartner]
		SET partnerID = UPPER(partnerID),
	    partnerName = UPPER(partnerName);

	--populate DimAgency
	---truncate table [NDWH].[dbo].[DimAgency]
	MERGE [NDWH].[dbo].[DimAgency] AS a
	USING(SELECT DISTINCT Agency ,Agency as AgencyName FROM [All_Staging_2016_2]..lkp_usgPartnerMenchanism) AS b 
	ON(a.AgencyID =b.Agency)
	WHEN MATCHED THEN
    UPDATE SET 
    a.AgencyName = B.Agency
	WHEN NOT MATCHED THEN 
	INSERT(AgencyID,AgencyName) VALUES(Agency,AgencyName);

	UPDATE  [NDWH].[dbo].[DimAgency]
		SET AgencyName = UPPER(AgencyName);

	UPDATE  a
	 SET 
	     a.AgencyKey = c.AgencyKey
	 FROM   [NDWH].[dbo].[DimPartner] a
	 LEFT OUTER JOIN  [NDWH].[dbo].[DimAgency] c on a.AgencyName = c.AgencyName;

	 UPDATE  a
	 SET 
	     a.AgencyKey = c.AgencyKey
	 FROM   [NDWH].[dbo].[DimFacility] a
	 LEFT OUTER JOIN  [NDWH].[dbo].[DimAgency] c on a.SDP_Agency = c.AgencyName;

	UPDATE  a
	 SET a.CountyKey = b.RegionKey,
	     a.AgencyKey = c.AgencyKey,
		 a.PartnerKey = d.PartnerKey
	 FROM   [NDWH].[dbo].[DimPartnerAndAgencyBridge] a
	 LEFT OUTER JOIN  [NDWH].[dbo].[DimRegion] b on a.CountyName = b.RegionName
	 LEFT OUTER JOIN  [NDWH].[dbo].[DimAgency] c on a.AgencyName = c.AgencyName
	 LEFT OUTER JOIN  [NDWH].[dbo].[DimPartner] d on a.PartnerName = d.PartnerName

	--populate DimPatientType
	MERGE [NDWH].[dbo].[DimPatientType] AS a
	USING(SELECT DISTINCT PatientType,PatientType as PatientTypeName  FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Patients]) AS b 
	ON(a.PatientTypeID =b.PatientType)
	WHEN MATCHED THEN
    UPDATE SET 
    a.PatientTypeName = B.PatientTypeName
	WHEN NOT MATCHED THEN 
	INSERT(PatientTypeID,PatientTypeName) VALUES(PatientType,PatientTypeName);

		--populate DimPopulationType

	MERGE [NDWH].[dbo].[DimPopulationType] AS a
	USING(SELECT DISTINCT PopulationType,PopulationType as PopulationTypeName  FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Patients]) AS b 
	ON(a.PopulationTypeID =b.PopulationType)
	WHEN MATCHED THEN
    UPDATE SET 
    a.PopulationType = B.PopulationTypeName
	WHEN NOT MATCHED THEN 
	INSERT(PopulationTypeID,PopulationType) VALUES(PopulationType,PopulationTypeName);

	--populate DimRegion
	--truncate table [NDWH].[dbo].[DimRegion]
	--select * from [NDWH].[dbo].[DimRegion] 
	MERGE [NDWH].[dbo].[DimRegion] AS a
	USING(SELECT DISTINCT county,county as RegionName  FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[DimFacilities]) AS b 
	ON(a.RegionID =b.county)
	WHEN MATCHED THEN
    UPDATE SET 
    a.RegionID = B.RegionName
	WHEN NOT MATCHED THEN 
	INSERT(RegionID,RegionName) VALUES(county,RegionName);

	UPDATE [NDWH].[dbo].[DimRegion]
	SET RegionName = UPPER(RegionName),
	SubCounty = UPPER(SubCounty);

		--populate DimVillage
   -- truncate table [NDWH].[dbo].[DimVillage]
	MERGE [NDWH].[dbo].[DimVillage] AS a
	USING(SELECT DISTINCT Location,Location as VillageName  FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[DimFacilities] WHERE Location IS NOT NULL OR Location !=NULL OR Location !='' ) AS b 
	ON(a.VillageID =b.Location)
	WHEN MATCHED THEN
    UPDATE SET 
    a.VillageName = B.VillageName
	WHEN NOT MATCHED THEN 
	INSERT(VillageID,VillageName) VALUES(Location,VillageName);

	--populate DimSubCounty
	---Truncate table [NDWH].[dbo].[DimSubCounty] 
	MERGE [NDWH].[dbo].[DimSubCounty] AS a
	USING(SELECT DISTINCT County,District,District as SubcountyName  FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[DimFacilities]) AS b 
	ON(a.SubcountyID =b.District)
	--WHEN MATCHED THEN
 --   UPDATE SET 
    --a.SubcountyName = B.SubcountyName
	WHEN NOT MATCHED THEN 
	INSERT(County,SubcountyID,SubcountyName) VALUES(County,District,SubcountyName);

	UPDATE  a
	 SET a.DistrictKey = b.SubCountyKey	     
	 FROM   [NDWH].[dbo].[DimFacility] a
	 LEFT OUTER JOIN  [NDWH].[dbo].[DimSubCounty] b on a.District = b.SubCountyName;
	 

	 UPDATE  a
	 SET a.RegionKey = c.RegionKey
	 FROM [NDWH].[dbo].[DimSubCounty] a
	 LEFT OUTER JOIN [NDWH].[dbo].[DimRegion] c on a.County = c.RegionID;

	 UPDATE a
	 set [SubCountyName] = upper([SubCountyName])
	 FROM [NDWH].[dbo].[DimSubCounty]  a;
	
	----DimEMR
	MERGE [NDWH].[dbo].[DimEMR] AS a
	USING(SELECT DISTINCT EMR,EMR AS EMRName FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Patients]) AS b 
	ON(a.[EMRID]=b.[EMR])
	WHEN MATCHED THEN
    UPDATE SET 
    a.EMRID = B.[EMRName]
	WHEN NOT MATCHED THEN 
	INSERT(EMRID,EMRDesription) VALUES(EMR,EMRName);


	----DimVisitType
	MERGE [NDWH].[dbo].[Dimvisittype] AS a
	USING(SELECT DISTINCT visittype,visittype AS visittypeName FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Patientvisits]) AS b 
	ON(a.[visittypeID]=b.[visittype])
	--WHEN MATCHED THEN
 --   UPDATE SET 
 --   a.visittypeID = B.[visittypeName]
	WHEN NOT MATCHED THEN 
	INSERT(visittypeID,visittypeDesription) VALUES(visittype,visittypeName);


		----DimProject
		--truncate table [NDWH].[dbo].[DimProject]
	MERGE [NDWH].[dbo].[DimProject] AS a
	USING(SELECT DISTINCT project,project AS projectName FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Patients]) AS b 
	ON(a.[projectID]=b.[project])
	WHEN MATCHED THEN
    UPDATE SET 
    a.projectID = B.[projectName]
	WHEN NOT MATCHED THEN 
	INSERT(projectID,projectName) VALUES(project,projectName);

	UPDATE [NDWH].[dbo].[DimProject]
	SET projectID =UPPER(projectID),
	    projectName = UPPER(projectName)


			----DimVaccinationStatus
	--Truncate table [NDWH].[dbo].[Dimvaccinationstatus]
	MERGE [NDWH].[dbo].[Dimvaccinationstatus] AS a
	USING(SELECT DISTINCT VaccinationStatus,VaccinationStatus AS VaccinationStatusName FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_covid]
	where VaccinationStatus is not null and VaccinationStatus !='') AS b 
	ON(a.[VaccinationStatusID]=b.[VaccinationStatus])
	WHEN MATCHED THEN
    UPDATE SET 
    a.VaccinationStatusID = B.[VaccinationStatus]
	WHEN NOT MATCHED THEN 
	INSERT(VaccinationStatusID,VaccinationStatus) VALUES(VaccinationStatus,VaccinationStatusName);

	UPDATE [NDWH].[dbo].[Dimvaccinationstatus]
	SET VaccinationStatusID =UPPER(VaccinationStatusID),
	    VaccinationStatus = UPPER(VaccinationStatus)


				----DimVaccineDoseType
	MERGE [NDWH].[dbo].[DimVaccineDoseType] AS a
	USING(SELECT DISTINCT FirstDoseVaccineAdministered,FirstDoseVaccineAdministered AS DoseName FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_covid]) AS b 
	ON(a.[VaccineDoseTypeID]=b.[FirstDoseVaccineAdministered])
	WHEN MATCHED THEN
    UPDATE SET 
    a.VaccineDoseTypeID = B.[DoseName]
	WHEN NOT MATCHED THEN 
	INSERT([VaccineDoseTypeID],[VaccineName]) VALUES(FirstDoseVaccineAdministered,DoseName);

	----DimProphylaxisType
	MERGE [NDWH].[dbo].[DimProphylaxisType] AS a
	USING(SELECT DISTINCT ProphylaxisType,ProphylaxisType AS ProphylaxisTypeDescr FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_PatientPharmacy]) AS b 
	ON(a.[ProphylaxisTypeID]=b.[ProphylaxisType])
	WHEN MATCHED THEN
    UPDATE SET 
    a.ProphylaxisTypeID = B.[ProphylaxisType]
	WHEN NOT MATCHED THEN 
	INSERT([ProphylaxisTypeID],[ProphylaxisType]) VALUES([ProphylaxisType],ProphylaxisTypeDescr);


	
	----DimTreatmentType
	MERGE [NDWH].[dbo].[DimTreatmentType] AS a
	USING(SELECT DISTINCT TreatmentType,TreatmentType AS TreatmentTypeDescr FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_PatientPharmacy]) AS b 
	ON(a.[TreatmentTypeID]=b.TreatmentType)
	WHEN MATCHED THEN
    UPDATE SET 
    a.[TreatmentTypeID] = B.TreatmentType
	WHEN NOT MATCHED THEN 
	INSERT([TreatmentTypeID],[TreatmentType]) VALUES(TreatmentType,TreatmentTypeDescr);


		----DimDrug
		---truncate table [NDWH].[dbo].[DimDrug]
	MERGE [NDWH].[dbo].[DimDrug] AS a
	USING(SELECT DISTINCT Drug,Drug AS DrugName FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_PatientPharmacy]) AS b 
	ON(a.[DrugID]=b.Drug)
	WHEN MATCHED THEN
    UPDATE SET 
    a.Drug = B.Drug
	WHEN NOT MATCHED THEN 
	INSERT([DrugID],[Drug]) VALUES(Drug,DrugName);

	
		----[NDWH].[dbo].[DimExitReason]
		---truncate table [NDWH].[dbo].[DimExitReason]
	MERGE [NDWH].[dbo].[DimExitReason] AS a
	USING(SELECT DISTINCT ExitReason,ExitReason AS ExitReasonDescr FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_PatientStatus]) AS b 
	ON(a.[ExitReasonID]=b.ExitReason)
	WHEN MATCHED THEN
    UPDATE SET 
    a.ExitReason = B.ExitReason
	WHEN NOT MATCHED THEN 
	INSERT([ExitReasonID],ExitReason) VALUES(ExitReason,ExitReasonDescr);


     UPDATE [NDWH].[dbo].[DimExitReason]
	 SET ExitReason ='LOST TO FOLLOW UP'
	 WHERE [ExitReasonID] ='LTFU';

	----[NDWH].[dbo].[DimTBScreening]
		---truncate table [NDWH].[dbo].[DimTBScreening]
	MERGE [NDWH].[dbo].[DimTBScreening] AS a
	USING(SELECT DISTINCT TBScreening,TBScreening AS TBScreeningDescr FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_Ipt]) AS b 
	ON(a.[TBScreeningID]=b.TBScreening)
	WHEN MATCHED THEN
    UPDATE SET 
    a.TBScreening = B.TBScreening
	WHEN NOT MATCHED THEN 
	INSERT([TBScreeningID],TBScreening) VALUES(TBScreening,TBScreeningDescr);


     UPDATE [NDWH].[dbo].[DimTBScreening]
	 SET TBScreeningID ='UNDEFINED',TBScreening = 'UNDEFINED'
	 WHERE TBScreeningID is null;

	   UPDATE [NDWH].[dbo].[DimTBScreening]
	 SET TBScreening = upper(TBScreening);


	 ----[NDWH].[dbo].[DimSevereEvent]
		---truncate table [NDWH].[dbo].[DimSevereEvent]
	MERGE [NDWH].[dbo].[DimSevereEvent] AS a
	USING(SELECT DISTINCT [Severity_CleanUp],[Severity_CleanUp] AS Severity_CleanUpDescr FROM [ODS].[dbo].[STG_AdverseEvents]) AS b 
	ON(a.SevereEventID=b.[Severity_CleanUp])
	WHEN MATCHED THEN
    UPDATE SET 
    a.[SevereEvent] = B.[Severity_CleanUp]
	WHEN NOT MATCHED THEN 
	INSERT([SevereEventID],SevereEvent) VALUES([Severity_CleanUp],Severity_CleanUpDescr);

	UPDATE [NDWH].[dbo].[DimSevereEvent]
	 SET SevereEvent = upper(SevereEvent);
	 ---
----[NDWH].[dbo].[DimAdverseEvent]
		---truncate table [NDWH].[dbo].[DimAdverseEvent]
	MERGE [NDWH].[dbo].[DimAdverseEvent] AS a
	USING(SELECT DISTINCT [AdverseEvent_CleanUp],[AdverseEvent_CleanUp] AS AdverseEvent_CleanUpDescr FROM [ODS].[dbo].[STG_AdverseEvents]) AS b 
	ON(a.AdverseEventID=b.AdverseEvent_CleanUp)
	WHEN MATCHED THEN
    UPDATE SET 
    a.[AdverseEvent] = B.AdverseEvent_CleanUp
	WHEN NOT MATCHED THEN 
	INSERT([AdverseEventID],AdverseEvent) VALUES(AdverseEvent_CleanUp,AdverseEvent_CleanUpDescr);

	UPDATE [NDWH].[dbo].[DimAdverseEvent]
	 SET AdverseEvent = upper(AdverseEvent);

	----[NDWH].[dbo].[DimAdverseEventCause]
		---truncate table [NDWH].[dbo].[DimAdverseEventCause]
	MERGE [NDWH].[dbo].[DimAdverseEventCause] AS a
	USING(SELECT DISTINCT AdverseEventCause_cleanUp,AdverseEventCause_cleanUp AS AdverseEventCause_cleanUpDescr FROM [ODS].[dbo].[STG_AdverseEvents]) AS b 
	ON(a.AdverseEventCauseID=b.AdverseEventCause_CleanUp)
	WHEN MATCHED THEN
    UPDATE SET 
    a.AdverseEventCause = B.AdverseEventCause_CleanUp
	WHEN NOT MATCHED THEN 
	INSERT([AdverseEventCauseID],AdverseEventCause) VALUES(AdverseEventCause_cleanUp,AdverseEventCause_cleanUpDescr);

	UPDATE [NDWH].[dbo].[DimAdverseEventCause]
	 SET AdverseEventCause = upper(AdverseEventCause);

	 ----[NDWH].[dbo].[DimAdverseEventActionTaken]
		---truncate table [NDWH].[dbo].[DimAdverseEventActionTaken]
	MERGE [NDWH].[dbo].[DimAdverseEventActionTaken] AS a
	USING(SELECT DISTINCT AdverseEventActionTaken,AdverseEventActionTaken AS AdverseEventActionTakenDescr FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_AdverseEvents]) AS b 
	ON(a.AdverseEventActionTakenID=b.AdverseEventActionTakenDescr)
	WHEN MATCHED THEN
    UPDATE SET 
    a.AdverseEventActionTaken = B.AdverseEventActionTaken
	WHEN NOT MATCHED THEN 
	INSERT([AdverseEventActionTakenID],AdverseEventActionTaken) VALUES(AdverseEventActionTaken,AdverseEventActionTakenDescr);

	UPDATE [NDWH].[dbo].[DimAdverseEventActionTaken]
	 SET AdverseEventActionTaken = upper(AdverseEventActionTaken);

	----[NDWH].[dbo].[DimAdverseEventRegimen]
		---truncate table [NDWH].[dbo].[DimAdverseEventRegimen]
	MERGE [NDWH].[dbo].[DimAdverseEventRegimen] AS a
	USING(SELECT DISTINCT AdverseEventRegimen,AdverseEventRegimen AS AdverseEventRegimenDescr FROM [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_AdverseEvents] WHERE AdverseEventRegimen IS NOT NULL) AS b 
	ON(a.AdverseEventRegimenID=b.AdverseEventRegimen)
	WHEN MATCHED THEN
    UPDATE SET 
    a.AdverseEventRegimen = B.AdverseEventRegimen
	WHEN NOT MATCHED THEN 
	INSERT([AdverseEventRegimenID],AdverseEventRegimen) VALUES(AdverseEventRegimen,AdverseEventRegimenDescr);

	UPDATE [NDWH].[dbo].[DimAdverseEventRegimen]
	 SET AdverseEventRegimen = upper(AdverseEventRegimen);

	----LastRegimen
	   --truncate table [NDWH].[dbo].[DimLastRegimen]  
	MERGE [NDWH].[dbo].[DimLastRegimen] AS a
	USING(select distinct lTRIM(RTRIM(LastRegimen))LastRegimen from [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_ARTPatients] where RTRIM(LTRIM(LastRegimen)) is not null OR RTRIM(LTRIM(LastRegimen))!='' OR RTRIM(LTRIM(LastRegimen)) !=NULL

			union all
			select distinct lTRIM(RTRIM(PreviousARTRegimen))PreviousARTRegimen from [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_ARTPatients] where PreviousARTRegimen is not null OR PreviousARTRegimen !=''
			union all
			select distinct lTRIM(RTRIM(StartRegimen))StartRegimen from [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_ARTPatients] where StartRegimen is not null OR StartRegimen !=''
	) AS b 
		ON(a.LastRegimen=b.LastRegimen)
		--WHEN MATCHED THEN
		--UPDATE SET 
		--a.LastRegimen = B.LastRegimen
		WHEN NOT MATCHED THEN 
		INSERT(LastRegimen) VALUES(LastRegimen);

		with cte AS (
		Select
		LastRegimen,
		 ROW_NUMBER() OVER (PARTITION BY LastRegimen ORDER BY
		 LastRegimen ) Row_Num
		FROM [NDWH].[dbo].[DimLastRegimen](Nolock)
		)
		delete from cte 
		Where Row_Num >1;

	----PreviousARTRegimen
	   --truncate table [NDWH].[dbo].[DimLastRegimen]  
 
	MERGE [NDWH].[dbo].[DimPreviousARTRegimen] AS a
	USING( select LastRegimen from [NDWH].[dbo].[DimLastRegimen]) AS b 
		ON(a.PreviousARTRegimen=b.LastRegimen)
		WHEN MATCHED THEN
		UPDATE SET 
		a.PreviousARTRegimen = B.LastRegimen
		WHEN NOT MATCHED THEN 
		INSERT(PreviousARTRegimen) VALUES(LastRegimen);

	with cte AS (
		Select
		PreviousARTRegimen,
		 ROW_NUMBER() OVER (PARTITION BY PreviousARTRegimen ORDER BY
		 PreviousARTRegimen ) Row_Num
		FROM [NDWH].[dbo].[DimPreviousARTRegimen](Nolock)
		)
		delete from cte 
		Where Row_Num >1;

	----[NDWH].[dbo].[DimStartRegimen]
	   --truncate table [NDWH].[dbo].[DimStartRegimen]
 
	MERGE [NDWH].[dbo].[DimStartRegimen] AS a
	USING( select LastRegimen from [NDWH].[dbo].[DimLastRegimen]) AS b 
		ON(a.StartRegimen=b.LastRegimen)
		WHEN MATCHED THEN
		UPDATE SET 
		a.StartRegimen = B.LastRegimen
		WHEN NOT MATCHED THEN 
		INSERT(StartRegimen) VALUES(LastRegimen);

	----DimStartRegimenLine
	   --truncate table [NDWH].[dbo].[DimStartRegimenLine]
	MERGE [NDWH].[dbo].[DimStartRegimenLine] AS a
	USING(select distinct StartRegimenLine from [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_ARTPatients] with(NoLock) 
		  where StartRegimenLine !='' and ltrim(rtrim(StartRegimenLine)) is not null and StartRegimenLine !='null'
			union all
		 select distinct ltrim(rtrim(LastRegimenLine))LastRegimenLine from [10.230.50.60].[All_Staging_2016_2].[dbo].[stg_ARTPatients]with(NoLock)
		where LastRegimenLine is not null and ltrim(rtrim(LastRegimenLine)) !='' and StartRegimenLine !='null'
	) AS b 
		ON(a.StartRegimenLine=b.StartRegimenLine)
		--WHEN MATCHED THEN
		--UPDATE SET 
		--a.StartRegimenLine = B.StartRegimenLine
		WHEN NOT MATCHED THEN 
		INSERT(StartRegimenLine) VALUES(StartRegimenLine);

		
	with cte AS (
		Select
		StartRegimenLine,
		 ROW_NUMBER() OVER (PARTITION BY StartRegimenLine ORDER BY
		 StartRegimenLine ) Row_Num
		FROM [NDWH].[dbo].[DimStartRegimenLine](Nolock)
		)
		delete from cte 
		Where Row_Num >1;

		----PreviousARTRegimen
	   --truncate table [NDWH].[dbo].[DimLastRegimenLine] 
 
	MERGE [NDWH].[dbo].[DimLastRegimenLine] AS a
	USING( select StartRegimenLine from [NDWH].[dbo].[DimStartRegimenLine]) AS b 
		ON(a.LastRegimenLine=b.StartRegimenLine)
		WHEN MATCHED THEN
		UPDATE SET 
		a.LastRegimenLine = B.StartRegimenLine
		WHEN NOT MATCHED THEN 
		INSERT(LastRegimenLine) VALUES(StartRegimenLine);
END