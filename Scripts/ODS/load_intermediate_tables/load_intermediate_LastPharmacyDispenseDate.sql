IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastPharmacyDispenseDate]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastPharmacyDispenseDate];
BEGIN
	--Load_LastPharmacyDispenseDate
	With LastPharmacyDispenseDate AS (
	SELECT  row_number() OVER (PARTITION BY PatientID ,SiteCode,PatientPK ORDER BY DispenseDate DESC) AS NUM,
		PatientID ,
		SiteCode,
		PatientPK,
		convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2) PatientPKHash,
		convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2)PatientIDHash,
		DispenseDate as LastDispenseDate,
	CASE WHEN ExpectedReturn IS NULL THEN DATEADD(dd,30,DispenseDate) ELSE ExpectedReturn End AS ExpectedReturn,
	cast(getdate() as date) as LoadDate
	FROM ODS.dbo.CT_PatientPharmacy
	 )
	 Select LastPharmacyDispenseDate.* 
	 INTO [ODS].[dbo].[Intermediate_LastPharmacyDispenseDate]
	 from LastPharmacyDispenseDate
	 where NUM=1
END
