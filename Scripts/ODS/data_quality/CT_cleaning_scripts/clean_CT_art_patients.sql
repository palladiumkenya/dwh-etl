-- clean DOB
UPDATE [ODS].[DBO].[CT_ARTPatients] 
    SET DOB = NULL
WHERE DOB < CAST('1900-01-01' AS DATE) OR DOB >  GETDATE()

GO

-- clean StartARtDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET StartARTDate = NULL
WHERE StartARTDate < CAST('1980-01-01' AS DATE) OR StartARTDate > GETDATE()

GO

-- clean StartARTAtThisFacility
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET StartARTAtThisFacility = NULL
WHERE StartARTAtThisFacility < CAST('1980-01-01' AS DATE) OR StartARTAtThisFacility > GETDATE()

GO

-- clean LastARTDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET LastARTDate = NULL
WHERE LastARTDate < CAST('1980-01-01' AS DATE) OR LastARTDate > GETDATE()

GO

-- clean RegistrationDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET RegistrationDate = NULL
WHERE RegistrationDate < CAST('1980-01-01' AS DATE) OR RegistrationDate > GETDATE()

GO

-- clean PreviousARTStartDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET PreviousARTStartDate = NULL
WHERE PreviousARTStartDate < CAST('1980-01-01' AS DATE) OR PreviousARTStartDate > GETDATE()

GO

-- clean ExpectedReturn
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET ExpectedReturn = NULL
WHERE ExpectedReturn < CAST('1980-01-01' AS DATE) 

GO

-- clean LastVisit
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET LastVisit = NULL
WHERE LastVisit < CAST('1980-01-01' AS DATE) OR LastVisit > GETDATE()

GO

-- clean ExitDate
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET ExitDate = NULL
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
INNER JOIN ods.dbo.lkp_exit_reason ON lkp_exit_reason.source_name = ARTPatients.ExitReason

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
INNER JOIN ods.dbo.lkp_regimen ON lkp_regimen.source_name = ARTPatients.PreviousARTRegimen

GO

-- clean LastRegimen
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET LastRegimen = lkpRegimen.target_name 
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN ODS.dbo.lkp_regimen AS lkpRegimen ON lkpRegimen.source_name = ARTPatients.LastRegimen


GO

-- StartRegimen
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET StartRegimen = lkp_regimen.target_name 
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN ods.dbo.lkp_regimen ON lkp_regimen.source_name = ARTPatients.StartRegimen

GO

-- clean PatientSource
UPDATE [ODS].[DBO].[CT_ARTPatients]
    SET PatientSource = lkp_patient_source.target_name 
FROM [ODS].[DBO].[CT_ARTPatients] AS ARTPatients
INNER JOIN ods.dbo.lkp_patient_source ON lkp_patient_source.source_name = ARTPatients.PatientSource

GO


--  clean Start RegimenLine
UPDATE ODS.dbo.CT_ARTPatients  SET StartRegimenLine = CASE
                WHEN StartRegimenLine  in ('1','1st Alternative','1st line','Adult ART FirstLine','Adult first line','Child first line','First line','First line substitute','Paeds ART FirstLine') THEN  'First Line'
				WHEN StartRegimenLine in  ('2','2nd line','Adult ART SecondLine','Adult second line','Paeds ART Secondline','Second line','Second line substitute') Then 'Second Line'
                WHEN StartRegimenLine in ('3','Adult ART ThirdLine','Third line') Then 'Third Line'
                WHEN StartRegimenLine in ('PMTCT Maternal Regimens','PMTCT Regimens','') Then 'PMTCT'
                WHEN StartRegimenLine in ('Other','Adult intensive') Then 'Other'
                END 



GO
--  clean Last RegimenLine
UPDATE ODS.dbo.CT_ARTPatients  SET LastRegimenLine = CASE
                WHEN LastRegimenLine  in ('1','1st Alternative','1st line','Adult ART FirstLine','Adult first line','Child first line','First line','First line substitute','Paeds ART FirstLine') THEN  'First Line'
				WHEN LastRegimenLine in  ('2','2nd line','Adult ART SecondLine','Adult second line','Paeds ART Secondline','Second line','Second line substitute') Then 'Second Line'
                WHEN LastRegimenLine in ('3','Adult ART ThirdLine','Third line') Then 'Third Line'
                WHEN LastRegimenLine in ('PMTCT Maternal Regimens','PMTCT Regimens','') Then 'PMTCT'
                WHEN LastRegimenLine in ('Other','Adult intensive') Then 'Other'
                END 
