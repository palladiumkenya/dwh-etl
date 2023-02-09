IF OBJECT_ID(N'[NDWH].[dbo].[DimPatient]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[DimPatient];
BEGIN
	with ct_patient_source as (
		select
			distinct
            patients.PatientIDHash,
            patients.PatientPKHash,
            patients.PatientID,
            patients.PatientPK,
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
            distinct HTSNumberHash,
            PatientPKHash,
            PatientPK,
            SiteCode,
            cast(DOB as date) as DOB,
            Gender,
            MaritalStatus,
            NUPI
        from ODS.dbo.HTS_clients as clients
    ),
    prep_patient_source as (
    select 
        distinct PatientPkHash,
        PatientPk,
        PrepNumber,
        SiteCode,
        PrepEnrollmentDate,
        Sex,
        DateofBirth,
        ClientType,
        MaritalStatus
    from ODS.dbo.PrEP_Patient
    ),
    combined_data as (
        select
            coalesce(ct_patient_source.PatientPKHash, hts_patient_source.PatientPKHash, prep_patient_source.PatientPKHash) as PatientPKHash,
            coalesce(ct_patient_source.SiteCode, hts_patient_source.SiteCode, prep_patient_source.SiteCode) as SiteCode,
            coalesce(ct_patient_source.NUPI, hts_patient_source.NUPI) as NUPI,
            coalesce(ct_patient_source.DOB, hts_patient_source.DOB, prep_patient_source.DateofBirth) as DOB,
            coalesce(ct_patient_source.MaritalStatus, hts_patient_source.MaritalStatus, prep_patient_source.MaritalStatus) as MaritalStatus,
            coalesce(ct_patient_source.Gender, hts_patient_source.Gender, prep_patient_source.Sex) as Gender,
            ct_patient_source.PatientIDHash,
            coalesce(ct_patient_source.PatientType, prep_patient_source.ClientType) as ClientType,
			ct_patient_source.PatientSource,
			ct_patient_source.EnrollmentWHOKey,
			ct_patient_source.DateEnrollmentWHOKey,
			ct_patient_source.BaseLineWHOKey,
			ct_patient_source.DateBaselineWHOKey,
			ct_patient_source.IsTXCurr,
            hts_patient_source.HTSNumberHash,
            prep_patient_source.PrepNumber,
            cast(format(prep_patient_source.PrepEnrollmentDate,'yyyyMMdd') as int) as PrepEnrollmentDateKey,
			cast(getdate() as date) as LoadDate
        from ct_patient_source 
        full join hts_patient_source on  hts_patient_source.PatientPK = ct_patient_source.PatientPK
            and ct_patient_source.SiteCode = hts_patient_source.SiteCode
        full join prep_patient_source on prep_patient_source.PatientPk = ct_patient_source.PatientPk
            and prep_patient_source.SiteCode = ct_patient_source.SiteCode
    )
	select
		PatientKey = IDENTITY(INT, 1, 1),
        combined_data.PatientIDHash,
		combined_data.PatientPKHash,
        combined_data.HtsNumberHash,
        combined_data.PrepNumber,
        combined_data.SiteCode,
        combined_data.NUPI,
        combined_data.DOB,
        combined_data.MaritalStatus,
        combined_data.Gender,
        combined_data.ClientType,
        combined_data.PatientSource,
        combined_data.EnrollmentWHOKey,
        combined_data.DateBaselineWHOKey,
        combined_data.BaseLineWHOKey,
        combined_data.PrepEnrollmentDateKey,
        combined_data.IsTXCurr,
        combined_data.LoadDate
	into NDWH.dbo.DimPatient
	from combined_data;

ALTER TABLE NDWH.dbo.DimPatient ADD PRIMARY KEY(PatientKey);

END