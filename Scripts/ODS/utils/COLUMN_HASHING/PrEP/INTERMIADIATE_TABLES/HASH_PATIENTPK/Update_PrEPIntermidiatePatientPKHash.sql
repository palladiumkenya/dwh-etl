update [ODS].[dbo].[Intermediate_PrepRefills]
	set PatientPkHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);