GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AggregateTimeToARTGrp]') AND type in (N'U'))
TRUNCATE TABLE [dbo].AggregateTimeToARTGrp
GO

INSERT INTO NDWH.dbo.AggregateTimeToARTGrp
select 
MFLCode,
FacilityName,
--County,
--Subcounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
--Gender,
g.DATIMAgeGroup as AgeGroup,
Year(StartARTDateKey) StartART_Year,
DateName(Month,StartARTDateKey) StartART_Month,
--TimeToARTDiagnosis_Grp,
Count(*)NumPatients,
SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey)) AS TotalBySite,
cast((cast(Count(*) as decimal (9,2))/
	SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey))*100) 
as decimal(8,2))  AS proportions
from NDWH.dbo.FactART it
INNER join NDWH.dbo.DimAgeGroup g on g.Age=it.AgeAtEnrol
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
where MFLCode>1
Group BY MFLCode,FacilityName,County,Subcounty,a.AgencyName,g.DATIMAgeGroup,Year(StartARTDateKey),DateName(Month,StartARTDateKey)
order by MFLCode,Year(StartARTDateKey)