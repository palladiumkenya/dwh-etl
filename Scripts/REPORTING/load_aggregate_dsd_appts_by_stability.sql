IF  EXISTS (SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSDApptsByStability]') AND type in (N'U'))
TRUNCATE TABLE [REPORTING].[dbo].[AggregateDSDApptsByStability]
GO

INSERT INTO REPORTING.dbo.AggregateDSDApptsByStability (MFLCode,FacilityName,County,SubCounty,CTPartner,CTAgency,Gender,AgeGroup, AppointmentsCategory,StabilityAssessment,Stability, patients_number)
SELECT 
MFLCode,
FacilityName,
County,
SubCounty,
PartnerName,
AgencyName,
Gender,
AgeGroup, 
AppointmentsCategory,
StabilityAssessment,
Stability,
count(isTXCurr) patients_number
FROM (
	SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup as AgeGroup, 
	Case when ABS(DATEDIFF(DAY,LastVisitDate,NextAppointmentDate)) <=89 THEN '<3 Months'
		when ABS(DATEDIFF(DAY,LastVisitDate,NextAppointmentDate)) >=90 and ABS(DATEDIFF(DAY,LastVisitDate,NextAppointmentDate)) <=150 THEN '<3-5 Months'
		When ABS(DATEDIFF(DAY,LastVisitDate,NextAppointmentDate)) >151 THEN '>6+ Months'
		Else 'Unclassified' END as AppointmentsCategory,
	StabilityAssessment,
	Case when StabilityAssessment= 'Unstable' Then 0
		when StabilityAssessment= 'Stable' Then 1
		else '999' END as Stability,
	isTXCurr

	FROM NDWH.dbo.FactLatestObs lob
	INNER JOIN NDWH.dbo.DimAgeGroup age on age.AgeGroupKey = lob.AgeGroupKey
	INNER JOIN NDWH.dbo.DimFacility f on f.FacilityKey = lob.FacilityKey
	INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = lob.AgencyKey
	INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = lob.PatientKey
	INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = lob.PartnerKey
	INNER JOIN NDWH.dbo.FactART art on art.PatientKey = lob.PatientKey
	WHERE pat.isTXCurr = 1
) A
GROUP BY MFLCode, FacilityName, County, SubCounty, PartnerName, AgencyName, Gender, AgeGroup, StabilityAssessment, AppointmentsCategory, Stability
GO
