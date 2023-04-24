IF OBJECT_ID(N'[PMTCTRRI.dbo.MissedviralLoad]', N'U') IS NOT NULL 
	DROP TABLE [PMTCTRRI.dbo.MissedviralLoad];
BEGIN

with MFL_partner_agency_combination as (
	select 
		distinct MFL_Code,
        Facility_Name,
		SDP,
	    SDP_Agency as Agency,
        County,
        SubCounty,
        case when EMR in ('KenyaEMR',' IQCare-KeHMIS','AMRS','DREAMSOFTCARE','ECare','kenyaEMR') Then 'EMR Based'
        When EMR in ('No EMR','No-EMR','NonEMR') Then 'Paper Based' Else 'Unclassified' End as Facilitytype
	from ODS.dbo.All_EMRSites 
),
ViralLoad As (
    Select 
        PatientPK,
        MFLCode,
        VL.FacilityName,
        VL.PartnerName,
        VL.AgencyName,
        VL.County,
        VL.SubCounty,
        VL.AgeGroup,
            Case when DATEDIFF(month,StartARTDate, GETDATE()) >=3 Then 1 
            When  DATEDIFF(month,StartARTDate, GETDATE()) <3 Then 0 
            Else Null End AS EligibleVL,
        LatestVL1,
        VL1date.[Date] as VL1Date,
            Case  WHEN ISNUMERIC( LatestVL1) = 1 THEN 
            CASE WHEN CAST(Replace( LatestVL1,',','')AS FLOAT) <= 200.00 THEN 'Suppressed'
            WHEN CAST(Replace( LatestVL1,',','')AS FLOAT) > 200.00 THEN 'Unsuppressed' 
            Else Null end 
            ELSE CASE WHEN LatestVL1 IN ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') THEN 'Suppressed'
            ELSE NULL END END AS VLResult,
            
            CASE WHEN ISNUMERIC(LatestVL1) = 1 THEN 
            CASE WHEN datediff (month,VL1date.[Date], GETDATE())<=6 and CAST(Replace(LatestVL1,',','') AS FLOAT) <=200.00 THEN 1 
            WHEN datediff (month,VL1date.[Date], GETDATE())<=6 and CAST(Replace(LatestVL1,',','') AS FLOAT) > 200.00 THEN 0 ELSE NULL END ELSE CASE 
            WHEN datediff (month,VL1date.[Date], GETDATE())<=6 and LatestVL1 IN ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') THEN 1 ELSE NULL END END AS Suppressed,
        VL2date.[Date] as VL2Date,
        LatestVL2,
            Case when datediff (month,VL1date.[Date], GETDATE())<=6 Then 1 
            when datediff (month,VL1date.[Date], GETDATE()) >6 Then 0 
            Else Null end As VLDone
    from REPORTING.dbo.Linelist_FACTART ART
    Left join REPORTING.dbo.LineListViralLoad VL on VL.PatientPK=ART.PatientPKHash and VL.MFLCode=ART.SiteCode
    left join NDWH.dbo.DimDate VL1date on VL1date.DateKey= VL.LatestVLDate1Key
    left join NDWH.dbo.DimDate VL2date on VL2date.DateKey= VL.LatestVLDate2Key
    where VL.AgeGroup in ('1 to 4','10 to 14','Under 1','15 to 19') and ARTOutcome='V'

)
SELECT
    MFLCode,
    FacilityName,
    PartnerName,
    AgencyName,
    ViralLoad.County,
    ViralLoad.SubCounty,
    AgeGroup,
    Facilitytype,
    count (*)CALHIVTxCurr,
    Sum (EligibleVL) As EligibleVL,
    Sum (VLDone) As VLDone,
    Sum (Suppressed) As Suppressed,
    Sum (EligibleVL) -Sum (VLDone) As MissingVL
   into  PMTCTRRI.dbo.MissedViralLoad
from  ViralLoad
left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code=ViralLoad.MFLCode
Group by 
     MFLCode,
     FacilityName,
     PartnerName,
     AgencyName,
     ViralLoad.County,
     ViralLoad.SubCounty,
     AgeGroup,
     Facilitytype
END

