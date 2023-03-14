-- clean DateOfFirstSession
UPDATE [ODS].[DBO].[CT_EnhancedAdherenceCounselling]
    SET DateOfFirstSession = CAST('1900-01-01' AS DATE)
WHERE DateOfFirstSession < CAST('1900-01-01' AS DATE) OR DateOfFirstSession > GETDATE()

GO

-- clean EACFollowupDate
UPDATE [ODS].[DBO].[CT_EnhancedAdherenceCounselling]
    SET EACFollowupDate = CAST('1900-01-01' AS DATE)
WHERE EACFollowupDate < CAST('1900-01-01' AS DATE) OR DATEDIFF(day, GETDATE(), EACFollowupDate) > 365

GO