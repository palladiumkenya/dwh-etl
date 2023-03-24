IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_PregnancyDuringART]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_PregnancyDuringART];
BEGIN
	With PregnancyDuringART AS (
	SELECT  
		PatientID ,
		PatientPK ,
		SiteCode,
		MAX(PregnantDuringART)AS PregnantDuringART,
		 X.VisitDate,
		 StartARTDate,
		 cast(getdate() as date) as LoadDate
	FROM 
	(
	SELECT DISTINCT 
		Patients.PatientID ,
		Patients.PatientPK ,
		Patients.SiteCode, 
		VisitDate,
		StartARTDate,
			CASE WHEN VisitDate >= ART.StartARTDate THEN 1 ELSE 0 END AS PregnantDuringART
	 FROM [ODS].[DBO].[CT_PatientVisits] Visits
	 INNER JOIN [ODS].[DBO].[CT_Patient] Patients ON Visits.PatientID=Patients.PatientID AND Visits.PatientPK=Patients.PatientPK AND Patients.SiteCode=Visits.SiteCode
	 INNER JOIN [ODS].[DBO].[CT_ARTPatients] ART ON ART.PatientID=Patients.PatientID AND ART.PatientPK=Patients.PatientPK AND Patients.SiteCode=ART.SiteCode
	  WHERE Visits.Pregnant = 'Yes' OR Visits.Pregnant = 'Y'
  
	) X 
	GROUP BY PatientID ,PatientPK ,SiteCode,VisitDate,SiteCode,StartARTDate
	)
	Select 
			PregnancyDuringART.PatientID ,
			PregnancyDuringART.PatientPK ,
			cast( '' as nvarchar(100)) PatientPKHash,
			cast( '' as nvarchar(100)) PatientIDHash,
			PregnancyDuringART.SiteCode,
			PregnancyDuringART.PregnantDuringART,
			PregnancyDuringART.LoadDate
	 INTO [ODS].[dbo].[Intermediate_PregnancyDuringART]
	FROM  PregnancyDuringART
END

