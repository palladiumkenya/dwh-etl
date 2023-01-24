IF OBJECT_ID(N'[NDWH].[dbo].[DimPopulationType]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[DimPopulationType];
BEGIN
	with source_population_type as (
		select 
			distinct PopulationType
		from ODS.dbo.CT_Patient
		where PopulationType is not null
	)
	select 
		PopulationTypeKey = IDENTITY(INT, 1, 1),
		source_population_type.*,
		cast(getdate() as date) as LoadDate
	INTO [NDWH].[dbo].[DimPopulationType]
	from source_population_type;

	alter table NDWH.dbo.DimPopulationType add primary key(PopulationTypeKey);
END