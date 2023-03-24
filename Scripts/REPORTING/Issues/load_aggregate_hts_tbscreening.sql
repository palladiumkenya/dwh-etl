IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSTBscreening]') AND type in (N'U')) 
TRUNCATE TABLE REPORTING.[dbo].[AggregateHTSTBscreening]
GO

WITH tested AS (
    SELECT distinct 
        MFLCode,
        FacilityName,
        County,
        SubCounty,
        PartnerName,
        AgencyName,
        Gender,
        DATIMAgeGroup,
        tbScreening,
        case 
            when TBScreening IS NOT NULL THEN 'Screened for TB'
        ELSE 'Not Screened for TB' END AS TBScreening_Grp,
        year,
        month,
        FORMAT(cast(date as date), 'MMMM') MonthName,      
        Tested,        
        Positive,         
        Linked
    FROM NDWH.dbo.FactHTSClientTests hts
    LEFT join NDWH.dbo.DimFacility f on f.FacilityKey = hts.FacilityKey
    LEFT JOIN NDWH.dbo.DimAgency a on a.AgencyKey = hts.AgencyKey
    LEFT JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = hts.PatientKey
    LEFT join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
    LEFT JOIN NDWH.dbo.DimPartner p on p.PartnerKey = hts.PartnerKey
    LEFT JOIN NDWH.dbo.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
    LEFT JOIN NDWH.dbo.DimDate d on d.DateKey = hts.DateTestedKey
)
INSERT INTO REPORTING.dbo.AggregateHTSTBscreening (
	MFLCode, 
	FacilityName, 
	County, 
	SubCounty, 
	PartnerName, 
	AgencyName, 
	Gender, 
	AgeGroup,
	tbScreening, 
	TBScreening_Grp,
	year, 
	month, 
	MonthName, 
	Tested, 
	Positive, 
	Linked
)
SELECT 
    MFLCode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    Gender,
    DATIMAgeGroup as AgeGroup,
    tbScreening,
    TBScreening_Grp,
    year,
    month,
    MonthName,
    Sum(Tested) Tested,
    Sum(Positive) Positive,
    Sum(Linked) Linked
FROM tested
GROUP BY MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, DATIMAgeGroup, tbScreening, year, month, MonthName, TBScreening_Grp