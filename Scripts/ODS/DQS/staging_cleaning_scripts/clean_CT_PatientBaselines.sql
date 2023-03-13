
-- clean bWHODate
UPDATE [ODS].[DBO].[CT_PatientBaselines]
    SET bWHODate = CAST('1900-01-01' AS DATE)
WHERE bWHODate < CAST('1980-01-01' AS DATE) OR bWHODate > GETDATE()

GO

-- clean bCD4
UPDATE [ODS].[DBO].[CT_PatientBaselines]
    SET bCD4 = 999
WHERE bCD4 < 0 

GO

-- clean bCD4Date
UPDATE [ODS].[DBO].[CT_PatientBaselines]
    SET bCD4Date = CAST('1900-01-01' AS DATE)
WHERE bCD4Date < CAST('1980-01-01' AS DATE) OR bCD4Date > GETDATE()

GO
