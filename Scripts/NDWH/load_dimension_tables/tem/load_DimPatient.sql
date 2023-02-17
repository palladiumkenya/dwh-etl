IF OBJECT_ID(N'[NDWH].[dbo].[DimPatient]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[DimPatient];
BEGIN
	with ct_patient_source as (
		select
			distinct
            patients.PatientID,
            cast(patients.PatientPK as int) as PatientPk,
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
	),
    hts_patient_source as (
        select    
            distinct HTSNumber,
            SiteCode,
			--CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(clients.PatientPk as NVARCHAR(36))), 2) as PatientPK,
            cast(PatientPK as int) as PatientPk,
            cast(DOB as date) as DOB,
            Gender,
            MaritalStatus,
            NUPI
        from ODS.dbo.HTS_clients as clients
    ),
    combined_data as (
        select
            coalesce(ct_patient_source.PatientPK, hts_patient_source.PatientPK) as PatientPK,
            coalesce(ct_patient_source.SiteCode, hts_patient_source.SiteCode) as SiteCode,
            coalesce(ct_patient_source.NUPI, hts_patient_source.NUPI) as NUPI,
            coalesce(ct_patient_source.DOB, hts_patient_source.DOB) as DOB,
            coalesce(ct_patient_source.MaritalStatus, hts_patient_source.MaritalStatus) as MaritalStatus,
            coalesce(ct_patient_source.Gender, hts_patient_source.Gender) as Gender,
            ct_patient_source.PatientID,
            ct_patient_source.PatientType,
			ct_patient_source.PatientSource,
			ct_patient_source.EnrollmentWHOKey,
			ct_patient_source.DateEnrollmentWHOKey,
			ct_patient_source.BaseLineWHOKey,
			ct_patient_source.DateBaselineWHOKey,
			ct_patient_source.IsTXCurr,
            hts_patient_source.HTSNumber,
			cast(getdate() as date) as LoadDate
        from ct_patient_source 
        full join hts_patient_source on ct_patient_source.PatientPK = hts_patient_source.PatientPK
            and ct_patient_source.SiteCode = hts_patient_source.SiteCode
    )
	select
		PatientKey = IDENTITY(INT, 1, 1),
        CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(combined_data.PatientID as NVARCHAR(36))), 2) as PatientID,
		CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(combined_data.PatientPk as NVARCHAR(36))), 2) as PatientPK,
        CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(combined_data.HtsNumber as NVARCHAR(36))), 2) as HTSNumber,
        combined_data.SiteCode,
        combined_data.NUPI,
        combined_data.DOB,
        combined_data.MaritalStatus,
        combined_data.Gender,
        combined_data.PatientType,
        combined_data.PatientSource,
        combined_data.EnrollmentWHOKey,
        combined_data.DateBaselineWHOKey,
        combined_data.BaseLineWHOKey,
        combined_data.IsTXCurr,
        combined_data.LoadDate
	into NDWH.dbo.DimPatient
	from combined_data;

ALTER TABLE NDWH.dbo.DimPatient ADD PRIMARY KEY(PatientKey);

END