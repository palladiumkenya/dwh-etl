USE [HIS_Implementation]
GO
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HIS_Implementation].[dbo].[EMRSites]') AND type in (N'U'))
DROP TABLE [HIS_Implementation].[dbo].[EMRSites]
GO

SELECT 
		MFL_Code as MFLCode,
		[Facility_Name] as FacilityName,
		County,
		SubCounty as Sub_County,
		[Owner] as [Ownership],
		SDP as CTPartner,
		[SDP_Agency] as CTAgency,
		[EMR_Status] as [Care & Treatment Implementation Status],
		[EMR] as [EMR IN USE],
		Project as Project
	INTO HIS_Implementation.[dbo].EMRSites
FROM HIS_Implementation.[dbo].[ALL_EMRSites]
WHERE Implementation in ('C&T','CT','CT & HTS','CT & HTS', 'CT & HTS & IL','CT & IL','CT & KP','CT & KP & HTS','CT Only')
 AND [EMR_Status]='Active'

GO