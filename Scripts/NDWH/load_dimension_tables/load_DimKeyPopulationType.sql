with source_key_population_type as (
	select 
		distinct KeyPopulationType
	from ODS.dbo.CT_Patient
	where KeyPopulationType is not null
)
select 
    KeyPopulationTypeKey = IDENTITY(INT, 1, 1),
    source_key_population_type.*,
	cast(getdate() as date) as LoadDate
into NDWH.dbo.DimKeyPopulationType
from source_key_population_type;

alter table NDWH.dbo.DimKeyPopulationType add primary key(KeyPopulationTypeKey);