-- clean Covid19AssessmentDate
UPDATE [ODS].[DBO].[CT_Covid]
    SET Covid19AssessmentDate = CAST('1900-01-01' AS DATE)
WHERE Covid19AssessmentDate < CAST('1980-01-01' AS DATE) OR Covid19AssessmentDate > GETDATE()

GO

-- clean DateGivenFirstDose
UPDATE [ODS].[DBO].[CT_Covid]
    SET DateGivenFirstDose = CAST('1900-01-01' AS DATE)
WHERE DateGivenFirstDose < CAST('1980-01-01' AS DATE) OR DateGivenFirstDose > GETDATE()

GO

-- clean DateGivenSecondDose
UPDATE [ODS].[DBO].[CT_Covid]
    SET DateGivenSecondDose = CAST('1900-01-01' AS DATE)
WHERE DateGivenSecondDose < CAST('1980-01-01' AS DATE) OR DateGivenSecondDose > GETDATE()


GO