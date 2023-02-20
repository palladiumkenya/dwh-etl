
update [ODS].[dbo].[Intermediate_PrepRefills]
	set PrepNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PrepNumber  as nvarchar(36))), 2);



