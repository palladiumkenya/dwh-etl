IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateKHIS_CT]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[AggregateKHIS_CT];

SELECT 
	
	DHISOrgId
	,MFLCode
	,FacilityName
	,facility.County
	,facility.SubCounty
	,Ward
	,ReportMonth_Year
	,Enrolled_Total
	,StartedART_Total
	,CurrentOnART_Total
	,CTX_Total
	,OnART_12Months
	,NetCohort_12Months
	,VLSuppression_12Months
	,VLResultAvail_12Months
	,createdAt
	,updatedAt
	,Start_ART_Under_1
	,Start_ART_1_9
	,Start_ART_10_14_M
	,Start_ART_10_14_F
	,Start_ART_15_19_M
	,Start_ART_15_19_F
	,Start_ART_20_24_M
	,Start_ART_20_24_F
	,Start_ART_25_Plus_M
	,Start_ART_25_Plus_F
	,On_ART_Under_1
	,On_ART_1_9
	,On_ART_10_14_M
	,On_ART_10_14_F
	,On_ART_15_19_M
	,On_ART_15_19_F
	,On_ART_20_24_M
	,On_ART_20_24_F
	,On_ART_25_Plus_M
	,On_ART_25_Plus_F
	,PartnerName
	, Agency as AgencyName
	,cast(getdate() as date) as LoadDate
INTO REPORTING.dbo.AggregateFACT_CT_DHIS2 
FROM NDWH.dbo.AggregateKHIS_CT as  CT
LEFT join NDWH.dbo.DimFacility facility on facility.FacilityKey=CT.facilitykey 
left join NDWH.dbo.DimPartner partner on partner.PartnerKey=ct.PartnerKey
 WHERE MFLCode IS NOT NULL;
