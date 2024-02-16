IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_Pbfw]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_Pbfw];		
select 
    distinct obs.SiteCode,
        obs.PatientPK,
        Breastfeeding,
        Pregnant
into ODS.dbo.Intermediate_Pbfw
from ODS.dbo.intermediate_LatestObs as obs
left join ODS.dbo.CT_ARTPatients as art_patient on art_patient.PatientPK = obs.PatientPK
    and art_patient.SiteCode = obs.SiteCode
where 
    Pregnant='Yes' OR breastfeeding='Yes'
    and 
    /*Check if period of gestation is within  9 months +6 for BF =15 */
    and  DATEDIFF(DAY, DATEADD(DAY, -(CAST(FLOOR(CONVERT(FLOAT, GestationAge)) * 7 AS INT)), CAST(LMP AS DATE)), GETDATE()) <= 450