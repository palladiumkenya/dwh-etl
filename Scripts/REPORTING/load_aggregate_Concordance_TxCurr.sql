IF OBJECT_ID(N'[REPORTING].[dbo].aggregate_concordance_txcurr', N'U') IS NOT NULL drop table [REPORTING].[dbo].aggregate_concordance_txcurr 
Select
   FacilityName,
   PartnerName,
   Agency,
   txcurr.EMR,
   KHIS_TxCurr,
   DWH_TxCurr,
   EMR_TxCurr,
   Diff_EMR_DWH,
   DiffKHISDWH,
   DiffKHISEMR,
   Proportion_variance_EMR_DWH,
   Proportion_variance_KHIS_DWH,
   Proportion_variance_KHIS_EMR into Reporting.dbo.aggregate_concordance_txcurr 
from
   NDWH.dbo.FACTTxCurrConcordance as txcurr 
   LEFT join
      NDWH.dbo.DimFacility fac 
      on fac.FacilityKey = txcurr.FacilityKey 
   LEFT JOIN
      NDWH.dbo.DimAgency agency 
      on agency.AgencyKey = txcurr.AgencyKey 
   LEFT JOIN
      NDWH.dbo.DimPartner pat 
      on pat.PartnerKey = txcurr.PartnerKey 
ORDER BY
   Proportion_variance_EMR_DWH DESC