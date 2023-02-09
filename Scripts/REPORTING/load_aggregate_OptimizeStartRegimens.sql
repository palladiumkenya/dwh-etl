IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateOptimizeStartRegimens]', N'U') IS NOT NULL	
	DROP  TABLE [REPORTING].[dbo].[AggregateOptimizeStartRegimens];
-- TODO:: Add Last12MVLResult
	SELECT 
        SiteCode,
        FacilityName,
        County, 
        Subcounty, 
        PartnerName,
        AgencyName,
        Agegroup,
        [DATIMAgeGroup],
        Gender,
        StartRegimen,
        StartARTMonth,
        StartARTYr,
        SUM(ISTxCurr)TXCurr,
        Firstregimen
        
	INTO REPORTING.[dbo].AggregateOptimizeStartRegimens
	FROM (
		Select 
		  SiteCode, 
		  FacilityName, 
		  County, 
		  Subcounty, 
		  PartnerName, 
	      AgencyName,
		  DateName(m, StartARTDate) AS StartARTMonth, 
		  Year(StartARTDate) AS StartARTYr, 
		  CASE WHEN StartRegimen like '3TC+DTG+TDF' THEN 'TLD' 
			  WHEN StartRegimen like '3TC+EFV+TDF' THEN 'TLE' 
			  WHEN StartRegimen like '%NVP%' THEN 'NVP' ELSE 'Other Regimen' END AS StartRegimen, 
		  StartRegimen As Firstregimen,  
		  Gender, 
		  Case WHEN floor(a.Age) < 15 then 'Child' WHEN floor(a.Age) >= 15 then 'Adult' ELSE 'Aii' End as Agegroup, 
		  DATIMAgeGroup, 
		  ISTxCurr 
		from 
		  REPORTING.dbo.Linelist_FACTART a 
		  INNER JOIN NDWH.dbo.DimAgeGroup b  on a.age = b.Age 
		where 
		  ISTxCurr = 1 ) H 
	Group By SiteCode, FacilityName,County, Subcounty, PartnerName,AgencyName,StartRegimen,Agegroup,[DATIMAgeGroup],Gender,StartARTMonth,StartARTYr,Firstregimen
	;
