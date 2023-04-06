-- clean DOB
UPDATE [ODS].[DBO].[CT_ARTPatients] 
    SET DOB = CAST('1900-01-01' AS DATE)
WHERE DOB < CAST('1900-01-01' AS DATE) OR DOB >  GETDATE()

GO

-- clean StartARtDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET StartARTDate = CAST('1900-01-01' AS DATE)
WHERE StartARTDate < CAST('1980-01-01' AS DATE) OR StartARTDate > GETDATE()

GO

-- clean StartARTAtThisFacility
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET StartARTAtThisFacility = CAST('1900-01-01' AS DATE)
WHERE StartARTAtThisFacility < CAST('1980-01-01' AS DATE) OR StartARTAtThisFacility > GETDATE()

GO

-- clean LastARTDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET LastARTDate = CAST('1900-01-01' AS DATE)
WHERE LastARTDate < CAST('1980-01-01' AS DATE) OR LastARTDate > GETDATE()

GO

-- clean RegistrationDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET RegistrationDate = CAST('1900-01-01' AS DATE)
WHERE RegistrationDate < CAST('1980-01-01' AS DATE) OR RegistrationDate > GETDATE()

GO

-- clean PreviousARTStartDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET PreviousARTStartDate = CAST('1900-01-01' AS DATE)
WHERE PreviousARTStartDate < CAST('1980-01-01' AS DATE) OR PreviousARTStartDate > GETDATE()

GO

-- clean ExpectedReturn
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET ExpectedReturn = CAST('1900-01-01' AS DATE)
WHERE ExpectedReturn < CAST('1980-01-01' AS DATE) 

GO

-- clean LastVisit
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET LastVisit = CAST('1900-01-01' AS DATE)
WHERE LastVisit < CAST('1980-01-01' AS DATE) OR LastVisit > GETDATE()

GO

-- clean ExitDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET ExitDate = CAST('1900-01-01' AS DATE)
WHERE ExitDate < CAST('1980-01-01' AS DATE) OR ExitDate > GETDATE()

GO

-- clean EMR 
UPDATE [ODS].[DBO].[CT_ARTPatients] 
    SET Emr = CASE
                WHEN Emr = 'Open Medical Records System - OpenMRS' THEN 'OpenMRS'
                WHEN Emr = 'Ampath AMRS' THEN 'AMRS'
            END
WHERE Emr IN ('Open Medical Records System - OpenMRS', 'Ampath AMRS')

GO

-- clean ExitReason
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET ExitReason = lkp_exit_reason.target_name
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN lkp_exit_reason ON lkp_exit_reason.source_name = ARTPatients.ExitReason

GO

--clean Project
UPDATE [ODS].[DBO].[CT_ARTPatients] 
    SET Project = CASE
                WHEN Project IN ('Ampathplus', 'AMPATH') THEN 'Ampath Plus'
                WHEN Project IN ('UCSF Clinical Kisumu', 'CHAP Uzima', 'DREAM', 'IRDO') THEN 'Kenya HMIS II'
            END
WHERE Project IN ('Ampathplus', 'AMPATH', 'UCSF Clinical Kisumu', 'CHAP Uzima', 'DREAM', 'IRDO')

GO


--clean Duration
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET Duration = 999
WHERE CAST(Duration AS FLOAT) < 0

GO

--clean AgeARTStart
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET AgeARTStart = 999
WHERE AgeARTStart < 0 OR AgeARTStart > 120

GO

--clean AgeLastVisit
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET AgeLastVisit = 999
WHERE AgeLastVisit < 0 OR AgeLastVisit > 120

GO

--clean AgeEnrollment
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET AgeEnrollment = 999
WHERE AgeEnrollment < 0 OR AgeEnrollment > 120

GO

-- clean PreviousARTRegimen
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET PreviousARTRegimen = lkp_regimen.target_name 
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN lkp_regimen ON lkp_regimen.source_name = ARTPatients.PreviousARTRegimen

GO

-- clean LastRegimen
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET LastRegimen = lkp_regimen.target_name 
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN ODS.dbo.lkp_regimen AS lkpRegimen ON lkpRegimen.source_name = ARTPatients.LastRegimen


GO

-- StartRegimen
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET StartRegimen = lkp_regimen.target_name 
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN lkp_regimen ON lkp_regimen.source_name = ARTPatients.StartRegimen

GO

-- clean PatientSource
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET PatientSource = lkp_patient_source.target_name 
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN lkp_patient_source ON lkp_patient_source.source_name = ARTPatients.PatientSource

GO


-- TODO: clean Start RegimenLine




-- TODO: clean Last RegimenLine
