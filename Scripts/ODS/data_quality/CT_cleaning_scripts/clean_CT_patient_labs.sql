-- clean TestName
UPDATE [ODS].[DBO].[CT_PatientLabs] 
    SET TestName = lkp_test_name.target_name
FROM [ODS].[DBO].[CT_PatientLabs] AS patient_labs
INNER JOIN ods.dbo.lkp_test_name ON lkp_test_name.source_name = patient_labs.TestName

GO

-- clean ReportedbyDate
UPDATE [ODS].[DBO].[CT_PatientLabs] 
    SET ReportedbyDate = NULL
WHERE ReportedbyDate < CAST('1900-01-01' AS DATE) OR ReportedbyDate > GETDATE()

GO

-- clean OrderedbyDate
UPDATE [ODS].[DBO].[CT_PatientLabs] 
    SET OrderedbyDate = NULL
WHERE OrderedbyDate < CAST('1900-01-01' AS DATE) OR OrderedbyDate > GETDATE()

GO


-- clean EMR 
UPDATE [ODS].[DBO].[CT_PatientLabs] 
    SET Emr = CASE
                WHEN Emr = 'Open Medical Records System - OpenMRS' THEN 'OpenMRS'
                WHEN Emr = 'Ampath AMRS' THEN 'AMRS'
            END
WHERE Emr IN ('Open Medical Records System - OpenMRS', 'Ampath AMRS')

GO

-- clean TestResult
UPDATE [ODS].[DBO].[CT_PatientLabs]
    SET TestResult = NULL
WHERE TRY_CAST(TestResult AS FLOAT) < 0
    AND TestName = 'Viral Load'

GO


