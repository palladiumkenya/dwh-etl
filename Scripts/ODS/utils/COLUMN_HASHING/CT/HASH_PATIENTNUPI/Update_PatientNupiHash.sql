

UPDATE ODS.dbo.CT_Patient 
	set NupiHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(Nupi  as nvarchar(36))), 2)
FROM ODS.dbo.CT_Patient 
where NupiHash is null;

UPDATE ODS.dbo.CT_Patient 
	set NupiHash = ''
FROM ODS.dbo.CT_Patient 
where Nupi ='';