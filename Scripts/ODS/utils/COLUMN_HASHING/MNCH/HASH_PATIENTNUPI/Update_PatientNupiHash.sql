UPDATE [ODS].[dbo].[MNCH_Patient]
	set NupiHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Nupi  as nvarchar(36))), 2)
FROM [ODS].[dbo].[MNCH_Patient] ;