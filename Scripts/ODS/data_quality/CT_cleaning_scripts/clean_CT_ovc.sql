UPDATE   [ODS].[DBO].[CT_Ovc] 
SET  [ODS].[DBO].[CT_Ovc].PartnerOfferingOVCServices= lkp_PartnerOfferingOVCServices.target_name  
from [ODS].[DBO].[CT_Ovc] 
INNER JOIN dbo.lkp_PartnerOfferingOVCServices  
ON [ODS].[DBO].[CT_Ovc].PartnerOfferingOVCServices = lkp_PartnerOfferingOVCServices.source_name
GO