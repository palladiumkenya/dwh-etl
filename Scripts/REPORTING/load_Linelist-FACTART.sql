IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NDWH.dbo.Linelist_FACTART]') AND type in (N'U'))
DROP TABLE [dbo].[NDWH.dbo.Linelist_FACTART]
GO

Select 
          
            pat.PatientID,
            pat.PatientPK,
            pat.Gender,
            pat.DOB,
            pat.MaritalStatus,
            pat.Nupi,
            pat.PatientSource,
            pat.PatientType,
            pat.SiteCode,
            fac.FacilityName,
            fac.County,
            fac.SubCounty,
            partner.PartnerName,
            agency.AgencyName,
            age.age,
            startdate.[Date] as StartARTDate,
            CurrentRegimen,
            CurrentRegimenline,
            StartRegimen,
            StartRegimenLine,
            AgeAtEnrol,
            AgeAtARTStart,
            TimetoARTDiagnosis,
            TimetoARTEnrollment,
            PregnantARTStart,
            PregnantAtEnrol,
            LastVisitDate,
            NextAppointmentDate,
            StartARTAtThisfacility,
            PreviousARTStartDate,
            PreviousARTRegimen,
            outcome.ARTOutcomeDescription,
            pat.ISTxCurr
         
INTO NDWH.dbo.Linelist_FACTART
from  NDWH.dbo.FACTART As ART 
left join NDWH.dbo.DimPatient pat on pat.PatientKey=ART.PatientKey
left join NDWH.dbo.DimPartner partner on partner.PartnerKey=ART.PartnerKey
left join NDWH.dbo.DimAgency agency on agency.AgencyKey=ART.AgencyKey
left join NDWH.dbo.DimFacility fac on fac.FacilityKey=ART.FacilityKey
left join NDWH.dbo.DimAgeGroup age on age.AgeGroupKey=ART.AgeGroupKey
left join NDWH.dbo.DimDate startdate on startdate.[Date]=ART.StartARTDateKey
left join NDWH.dbo.DimARTOutcome as outcome   on outcome.ARTOutcomeKey=ART.ARTOutcomeKey;


