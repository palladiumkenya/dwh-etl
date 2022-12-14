
with source_FamilyPlanning as (
select 
	distinct FamilyPlanningMethod as FamilyPlanning
from ODS.dbo.CT_PatientVisits
where FamilyPlanningMethod <> 'NULL' and FamilyPlanningMethod <>''
)
select
	FamilyPlanningKey = IDENTITY(INT, 1, 1),
	source_FamilyPlanning.*,
	cast(getdate() as date) as LoadDate
into dbo.DimFamilyPlanning
from source_FamilyPlanning;
ALTER TABLE dbo.DimFamilyPlanning ADD PRIMARY KEY(FamilyPlanningKey);