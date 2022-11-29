	with source_TreatmentType as (
	select 
		distinct TreatmentType as TreatmentType,
		case when TreatmentType in ('ARV','HIV Treatment') Then 'ART'
		when TreatmentType='Hepatitis B' Then 'Non-ART'
		Else TreatmentType End As TreatmentType_Cleaned
	from ODS.dbo.CT_PatientPharmacy
	where TreatmentType <> 'NULL' and TreatmentType <>''
	)
	select
		TreatmentTypeKey = IDENTITY(INT, 1, 1),
		source_TreatmentType.*,
		cast(getdate() as date) as LoadDate
	into dbo.DimTreatmentType
	from source_TreatmentType;
	ALTER TABLE dbo.DimTreatmentType ADD PRIMARY KEY(TreatmentTypeKey);