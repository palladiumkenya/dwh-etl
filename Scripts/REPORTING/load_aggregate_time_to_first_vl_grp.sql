IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToFirstVLGrp]') AND type in (N'U')) 
TRUNCATE TABLE [REPORTING].[dbo].[AggregateTimeToFirstVLGrp]
GO

INSERT INTO REPORTING.[dbo].[AggregateTimeToFirstVLGrp]
select 
MFLCode,
f.FacilityName,
County,
Subcounty,
p.PartnerName as CTPartner,
a.AgencyName as CTAgency,
Year(StartARTDateKey) StartART_Year,
DateName(Month,StartARTDateKey) StartART_Month,
TimeToFirstVLGrp,
Count(*) as NumPatients,
SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey)) AS TotalBySite,
cast((cast(Count(*) as decimal (9,2))/
	SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey))*100) 
as decimal(8,2))  AS proportions
FROM NDWH.dbo.FactViralLoads it
INNER join NDWH.dbo.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
where MFLCode>1
Group BY MFLCode,f.FacilityName,County,Subcounty,p.PartnerName,a.AgencyName,Year(StartARTDateKey),TimeToFirstVLGrp,DateName(Month,StartARTDateKey)
order by MFLCode,Year(StartARTDateKey),TimeToFirstVLGrp