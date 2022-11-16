with source_TreatmentType as (
select 
	distinct TreatmentType as TreatmentType
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