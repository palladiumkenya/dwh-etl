IF OBJECT_ID(N'[NDWH].[dbo].[DimPatient]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[DimPatient];
BEGIN
	with patient_source as (
		select
			distinct
			CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(patients.PatientID as NVARCHAR(36))), 2) as PatientID,
			CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(patients.PatientPK as NVARCHAR(36))), 2) as PatientPK,
			patients.SiteCode,
			Gender,
			cast(DOB as date) as DOB,
			MaritalStatus,
			Nupi,
			PatientType,
			PatientSource,
			baselines.eWHO as EnrollmentWHOKey,
			cast(format(eWHODate,'yyyyMMdd') as int) as DateEnrollmentWHOKey,
			bWHO as BaseLineWHOKey,
			cast(format(bWHODate,'yyyyMMdd') as int) as DateBaselineWHOKey,
			case 
				when outcomes.ARTOutcome =  'V' then 1
				else 0
			end as IsTXCurr,
			cast(getdate() as date) as LoadDate
		from 
		ODS.dbo.CT_Patient as patients
		left join ODS.dbo.CT_PatientBaselines as baselines on patients.PatientPK = baselines.PatientPK
			and patients.SiteCode = baselines.SiteCode
		left join ODS.dbo.Intermediate_ARTOutcomes as outcomes on outcomes.PatientPK = patients.PatientPK
			and outcomes.SiteCode = patients.SiteCode
	)
	select
		PatientKey = IDENTITY(INT, 1, 1),
		patient_source.*
	INTO [NDWH].[dbo].[DimPatient]
	from patient_source;

	ALTER TABLE NDWH.dbo.DimPatient ADD PRIMARY KEY(PatientKey);

END