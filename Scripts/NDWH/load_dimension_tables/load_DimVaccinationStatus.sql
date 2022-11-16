with source_vaccination_status as (
	select
		distinct VaccinationStatus
	from ODS.dbo.CT_Covid
	where VaccinationStatus <> '' and VaccinationStatus is not null
)
select 
    VaccinationStatusKey = IDENTITY(INT, 1, 1),
    source_vaccination_status.*,
	cast(getdate() as date) as LoadDate
into dbo.DimVaccinationStatus
from source_vaccination_status;

alter table dbo.DimVaccinationStatus add primary key(VaccinationStatusKey);