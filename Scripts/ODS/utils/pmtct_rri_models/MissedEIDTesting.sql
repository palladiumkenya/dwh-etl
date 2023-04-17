IF OBJECT_ID(N'[PMTCTRRI.dbo.MissedEIDTesting]', N'U') IS NOT NULL 
	DROP TABLE [PMTCTRRI.dbo.MissedEIDTesting];
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
HEIs As (
Select 
    hei.PatientPKHash,
    hei.sitecode ,
    enr.FirstEnrollmentAtMnch,
    enr.DOB,
    CONCAT(DATENAME(month,FirstEnrollmentAtMnch),' ',DATEPART(YEAR,FirstEnrollmentAtMnch)) As Period ,
    DATEDIFF(month,DOB,DNAPCR1Date) PCRduration,
    Case when DATEDIFF(month,DOB,DNAPCR1Date) <=2 Then 1 else 0 end As '0-2',
    Case When DATEDIFF(month,DOB,DNAPCR1Date) >2 and DATEDIFF(month,DOB,DNAPCR1Date) <=12 Then  1 else 0 end As '2-12',
    Case When DATEDIFF(month,DOB,DNAPCR1Date) > 12  Then  1 else 0 end As'Above1' ,
    Case When DOB is null or DNAPCR1Date is null   Then 1 else 0 end as 'MissingAge' ,
    hei.DNAPCR1,
    hei.DNAPCR1Date,
    mfl.County,
    mfl.SubCounty,
    mfl.Agency,
    mfl.Facility_Name,
    mfl.Facilitytype,
    mfl.SDP
    from ODS.dbo.MNCH_HEIs hei
    left join ODS.dbo.MNCH_Patient enr on hei.PatientPKHash=enr.PatientPKHash and hei.SiteCode=enr.SiteCode
    left join MFL_partner_agency_combination mfl on mfl.MFL_Code=hei.SiteCode
    where FirstEnrollmentAtMnch is not null and PatientHeiID is not null

),
PCR2Months As (
    Select 
        PatientPKHash ,
        Sitecode,
        County,
        SubCounty,
        Agency,
        Facility_Name,
        Facilitytype,
        SDP,
        count (*)HEIPCRAt2Months,
        CONCAT(DATENAME(month,FirstEnrollmentAtMnch),' ',DATEPART(YEAR,FirstEnrollmentAtMnch)) As Period 
    from HEIs
    where PCRduration <= 2
    Group by 
       PatientPKHash ,
        Sitecode,
        County,
        SubCounty,
        Agency,
        Facility_Name,
        Facilitytype,
        SDP,
       CONCAT(DATENAME(month,FirstEnrollmentAtMnch),' ',DATEPART(YEAR,FirstEnrollmentAtMnch))

)


Select 
        hei.County,
        hei.SubCounty,
        hei.SiteCode,
        hei.Facility_Name,
        hei.SDP,
        hei.Agency,
        hei.period,
        Count (*) As TotalHEI,
        count (HEIPCRAt2Months) As HEIPCRAt2Months,
        Count (*)-  count (HEIPCRAt2Months) As MissingPCRTests,
        sum ([0-2]) as Lessthan2Months,
        sum ([2-12]) As Within12Months,
        sum (Above1) As Above1Year,
        sum (MissingAge) As MissingAge
   into PMTCTRRI.dbo.MissedEIDTesting
   from HEIs hei
   left join PCR2Months pcr on pcr.PatientPKHash=hei.PatientPKHash
    and pcr.SiteCode=hei.sitecode
Group by 
        hei.County,
        hei.SubCounty,
        hei.SiteCode,
        hei.Facility_Name,
        hei.SDP,
        hei.Agency,
        hei.period
      
       
        
END
