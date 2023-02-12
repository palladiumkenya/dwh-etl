GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToARTGrp]') AND type in (N'U'))
TRUNCATE TABLE [dbo].AggregateTimeToARTGrp
GO

INSERT INTO [REPORTING].[dbo].[AggregateTimeToARTGrp]
           ([MFLCode]
           ,[FacilityName]
           ,[County]
           ,[Subcounty]
           ,[PartnerName]
           ,[AgencyName]
           ,[Gender]
           ,[AgeGroup]
           ,[StartARTYear]
           ,[StartARTMonth]
           ,[StartARTYearMonth]
           ,[NumPatients]
           ,[TotalBySite]
           ,[proportions])
select 
MFLCode,
f.FacilityName,
County,
Subcounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Gender,
g.DATIMAgeGroup as AgeGroup,
Year(StartARTDateKey) StartARTYear,
DateName(Month,StartARTDateKey) StartARTMonth,
convert(varchar(7),StartARTDateKey,126) as StartARTYearMonth,
--TimeToARTDiagnosis_Grp, TODO: This column has to be included in the FactART script
Count(*) as NumPatients,
SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey)) AS TotalBySite,
cast((cast(Count(*) as decimal (9,2))/
	SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey))*100) 
as decimal(8,2))  AS proportions
from NDWH.dbo.FactART it
INNER join NDWH.dbo.DimAgeGroup g on g.Age=it.AgeAtEnrol
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
where MFLCode>1
Group BY MFLCode,f.FacilityName,County,Subcounty,p.PartnerName,a.AgencyName,Gender,g.DATIMAgeGroup,Year(StartARTDateKey),DateName(Month,StartARTDateKey),
convert(varchar(7),StartARTDateKey,126)
order by MFLCode,Year(StartARTDateKey)