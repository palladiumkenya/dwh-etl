IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastEncounterHTSTests]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastEncounterHTSTests];

BEGIN
    with source_data as (
        select
            /* partition for the same SiteCode & PatientPK and pick the latest Encounter ID */
            distinct row_number() over (partition by SiteCode,PatientPK order by EncounterId desc) as num,
            TestDate,
            EncounterId,
            SiteCode,
            PatientPK,
            EMR, 
            Project,
            DateExtracted,
            EverTestedForHiv,
            MonthsSinceLastTest,
            ClientTestedAs ,
            EntryPoint,
            TestStrategy,
            TestResult1,
            TestResult2 ,
            FinalTestResult,
            PatientGivenResult ,
            TbScreening,
            ClientSelfTested,
            CoupleDiscordant,
            TestType,
            Consent  
        from ODS.dbo.HTS_ClientTests
        where FinalTestResult is not null and TestDate is not null and EncounterId is not null
    )
    select 
        source_data.*
    into ODS.dbo.Intermediate_LastEncounterHTSTests
    from source_data
    where num = 1

END