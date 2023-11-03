IF OBJECT_ID(N'[REPORTING].[dbo].LineListPBFW', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].LineListPBFW

GO


select  
    facility.MFLCode,
    facility.FacilityName,
    facility.County,
    facility.SubCounty,
    partner.PartnerName,
    agency.AgencyName,
    patient.Gender,
    patient.DOB,
    agegroup.DATIMAgeGroup as AgeGroup,
    anc1.Date as ANC1Date,
    anc2.Date as ANC2Date,
    anc3.Date as ANC3Date,
    anc4.Date as ANC4Date,
    KnownPositive,
    NewPositives as NewPositive,
    case 
        when RecieivedART = 1 and KnownPositive = 1 then  1 
        else 0 
    end as KnownPositiveOnART,
    case 
        when EligibleVL = 1 and KnownPositive = 1 then 1
        else 0
    end as KnowPositivesEligibleVL,
    case 
        when ValidVLResultCategory is not null and KnownPositive = 1 then 1
        else 0
    end as KnowPositivesValidVL,
    ValidVLResultCategory,
    case 
        when Suppressed = 1 and KnownPositive = 1 then 1 
        else 0
    end as KnowPositivesSupVL,
    case 
        when Unsuppressed = 1 and KnownPositive = 1 then 1
        else 0
    end as  KnowPositivesUnSupVL
into [REPORTING].[dbo].LineListPBFW
from NDWH.dbo.FactPBFW as pbfw
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = pbfw.PatientKey
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = pbfw.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.Partnerkey = pbfw.PartnerKey 
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = pbfw.AgencyKey 
left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey = pbfw.AgeGroupKey
left join NDWH.dbo.DimDate as anc1 on anc1.DateKey = ANCDate1Key
left join NDWH.dbo.DimDate as anc2 on anc2.DateKey = ANCDate2Key
left join NDWH.dbo.DimDate as anc3 on anc3.DateKey = ANCDate3Key
left join NDWH.dbo.DimDate as anc4 on anc4.DateKey = ANCDate4Key;