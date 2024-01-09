USE [HIS_Implementation]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[eHTSSites]') AND type in (N'U'))
DROP TABLE [dbo].[eHTSSites]

GO
SELECT  MFL_Code as MFLCode,
		[Facility_Name] as Facility,
		County,
		SubCounty as [Sub County],
		SDP,
		[SDP_Agency] as Agency,
		[EMR],
		[HTS_Status],
		Project,
		CASE WHEN [HTS_Deployment]='Desktop Only' OR [HTS_Deployment]= 'Hybrid' THEN 'Yes' 
			 END AS Desktop,
		CASE WHEN [HTS_Deployment] = 'Mobile Only' OR [HTS_Deployment]= 'Hybrid'THEN 'Yes' 
			END AS Mobile,
		CASE WHEN [HTS_Deployment]= 'Hybrid' THEN 'Yes' 
			END AS Hybrid
	INTO HIS_Implementation.dbo.eHTSSites
FROM HIS_Implementation.dbo.All_EMRSites 
	WHERE Implementation in ('CT & HTS','CT & HTS ','CT & HTS & IL','CT & KP & HTS','HTS Only')
	AND [HTS_Status] ='Active'