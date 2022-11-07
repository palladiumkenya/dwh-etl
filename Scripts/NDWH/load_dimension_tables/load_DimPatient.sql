--DimPatient Load
with patient_source as (
	select
		distinct
		CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(patients.PatientID as NVARCHAR(36))), 2) as PatientID,
		CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(patients.PatientPK as NVARCHAR(36))), 2) as PatientPK,
		patients.SiteCode,
		Gender,
		cast(DOB as date) as DOB,
		MaritalStatus,
		Nupi,
		PatientType,
		PatientSource,
		wabwhocd4.eWHO as EnrollmentWHOKey,
		cast(format(eWHODate,'yyyyMMdd') as int) as DateEnrollmentWHOKey,
		bWHO as BaseLineWHOKey,
		cast(format(bWHODate,'yyyyMMdd') as int) as DateBaselineWHOKey,
		cast(getdate() as date) as LoadDate
	from 
	All_Staging.dbo.stg_Patients as patients
	left join All_Staging.dbo.stg_PatientsWABWHOCD4 as wabwhocd4 on patients.PatientPK = wabwhocd4.PatientPK
		and patients.SiteCode = wabwhocd4.SiteCode
)
select
	patient_source.*
into dbo.DimPatient
from patient_source;