IF OBJECT_ID(N'PMTCTRRI.dbo.MissedDTGOptimization', N'U') IS NOT NULL 
	DROP TABLE PMTCTRRI.dbo.MissedDTGOptimization;

BEGIN

with facility_data as (
    select
        distinct MFL_Code,
        Facility_Name,
        SDP,
        SDP_Agency as Agency,
        County,
        SubCounty,
        case 
            when EMR in ('KenyaEMR',' IQCare-KeHMIS','AMRS','DREAMSOFTCARE','ECare','kenyaEMR') Then 'EMR Based'
            When EMR in ('No EMR','No-EMR','NonEMR') Then 'Paper Based' Else 'Unclassified' 
        End as Facilitytype
    from ODS.dbo.All_EMRSites
),
calhiv as (
    select 
        SiteCode,
        count(*) as calhiv 
    from REPORTING.dbo.Linelist_FACTART
    where  age <= 19
    group by 
        SiteCode   
),
on_dtg as (
    select 
        SiteCode,
        count(*) as calhiv_on_DTG
    from REPORTING.dbo.Linelist_FACTART
    where CurrentRegimen like '%DTG%'
        and age <= 19
    group by 
        SiteCode  
)
select 
    facility_data.Facility_Name,
    facility_data.MFL_Code,
    facility_data.County,
    facility_data.SubCounty,
    facility_data.SDP,
    facility_data.Agency,
    facility_data.Facilitytype,
    calhiv as CalHIV,
    calhiv_on_DTG as CalHIVOnDTG,
    calhiv - calhiv_on_DTG as CalHIVNotOnDTG
into PMTCTRRI.dbo.MissedDTGOptimization
from calhiv
left join on_dtg on on_dtg.SiteCode = calhiv.SiteCode
left join facility_data on facility_data.MFL_Code = calhiv.SiteCode


END