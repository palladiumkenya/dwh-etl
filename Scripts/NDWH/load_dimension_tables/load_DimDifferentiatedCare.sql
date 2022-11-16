--DimDifferentiatedCare
with source_DifferentiatedCare as (
select 
	distinct DifferentiatedCare as DifferentiatedCare
from ODS.dbo.CT_PatientVisits
where DifferentiatedCare <> 'NULL' and DifferentiatedCare <>''
)
select
	DifferentiatedCareKey = IDENTITY(INT, 1, 1),
	source_DifferentiatedCare.*,
	cast(getdate() as date) as LoadDate
into dbo.DimDifferentiatedCare
from source_DifferentiatedCare;
ALTER TABLE dbo.DimDifferentiatedCare ADD PRIMARY KEY(DifferentiatedCareKey);