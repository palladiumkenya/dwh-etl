IF OBJECT_ID(N'[PMTCTRRI.dbo.MissedMaternalHaart]', N'U') IS NOT NULL 
	DROP TABLE [PMTCTRRI.dbo.MissedMaternalHaart];
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
HIVPositiveANC As (
Select 
    PatientPKHash,
    sitecode ,
    VisitDate,
    HIVTestFinalResult
    from ODS.dbo.MNCH_AncVisits
    where HIVTestFinalResult='Positive'
UNION 
    SELECT
    PatientPKHash,
    sitecode ,
    VisitDate,
    HIVTestFinalResult
    from ODS.dbo.MNCH_PncVisits
    where HIVTestFinalResult='Positive' 
UNION 
    SELECT
    PatientPKHash,
    sitecode ,
    VisitDate,
    HIVTestFinalResult
    from ODS.dbo.MNCH_MatVisits
    where HIVTestFinalResult='Positive'
),
Combined As (Select 
ROW_NUMBER()OVER (PARTITION by SiteCode,PatientPKHash  ORDER BY VisitDate Asc ) As NUM ,
    PatientPKHash,
    Sitecode,
    Visitdate,
    CONCAT(DATENAME(month,VisitDate),' ',DATEPART(YEAR,VisitDate)) As Period,
    HIVTestFinalResult
 from HIVPositiveANC
),
Patients as (
    Select * from combined
    where Num=1
),
Linelist as (Select 
        Pat.PatientPKHash,
        Pat.SiteCode,
        Pat.VisitDate,
        Pat.[Period],
        Pat.HIVTestFinalResult,
        art.StartARTDate ,
        Case When art.StartARTDate < Pat.VisitDate Then  1 else 0 End as KnownPositive,
        Case When art.StartARTDate>=Pat.VisitDate Then 1 else 0 End As New ,
        --Case when art.StartARTDate < Pat.VisitDate and art.StartARTDate is not null Then 1 else 0 end as knownPositiveOnART,
        --Case when art.StartARTDate>=Pat.VisitDate  and art.StartARTDate is not null Then 1 else 0 end As NewOnART,
        mfl.County,
        mfl.SubCounty,
        mfl.Agency,
        mfl.Facility_Name,
        mfl.Facilitytype,
        mfl.SDP
from Patients as pat
left join ods.dbo.MNCH_Arts as art on pat.PatientPKHash=art.PatientPKHash
and pat.SiteCode=art.SiteCode
left join MFL_partner_agency_combination mfl on mfl.MFL_Code=pat.SiteCode
)


Select 
        County,
        SubCounty,
        linelist.SiteCode,
        Facility_Name,
        SDP,
        Agency,
        Facilitytype,
        [Period],
        Count (*) As HIVPosPreg,
        count (StartARTDate) As onART,
        Count (*) - count (StartARTDate) As NotonART,
        Sum (KnownPositive) As KnownPositives,
        Sum (New) As New
   into PMTCTRRI.dbo.MissedMaternalHaart
   from Linelist
Group by 
        County,
        SubCounty,
        linelist.Sitecode,
        Facility_Name,
        SDP,
        Agency,
        Facilitytype,
        [Period]
  
END