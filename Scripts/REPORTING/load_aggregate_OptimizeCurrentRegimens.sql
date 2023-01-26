IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[NDWH.[dbo].load_aggregate_OptimizeCurrentRegimens]') AND type in (N'U'))
	TRUNCATE TABLE NDWH.[dbo].load_aggregate_OptimizeCurrentRegimens;

	SELECT 
     SiteCode,
     FacilityName,
     County, 
     Subcounty, 
     PartnerName,
     AgencyName,
     Agegroup,
     DATIMAgeGroup,
     Gender,
     StartRegimen,
     StartARTMonth,
	 StartARTYr,
     SUM(ISTxCurr) As TXCurr,
     CurrentRegimen,
     RegimenLine,
     WeightBands,
     AgeBands
   
	INTO NDWH.[dbo].load_aggregate_OptimizeCurrentRegimens
	from (
	Select 
       cast (ART.SiteCode as nvarchar) As SiteCode,
       ART.FacilityName,
       ART.County, 
       ART.Subcounty, 
       PartnerName,
       AgencyName,
       DateName(m,StartARTDate) AS StartARTMonth,
       Year(StartARTDate) AS StartARTYr,
	CASE WHEN CurrentRegimen like '3TC+DTG+TDF' THEN 'TLD'
		 WHEN CurrentRegimen like '3TC+EFV+TDF' THEN 'TLE'
		 WHEN CurrentRegimen like '%NVP%' THEN 'NVP'
	ELSE  'Other Regimen' END AS CurrentRegimen,
    StartRegimen,
	Gender,
	CASE WHEN currentRegimenLine like 'First%' OR currentRegimenLine like '%PMTCT%' THEN 'First Regimen Line'
		 WHEN currentRegimenLine like 'Second%' THEN 'Second Regimen Line'
		 WHEN currentRegimenLine like 'Third%' THEN 'Third Regimen Line'
	ELSE 'Undocumented Regimen Line' END AS RegimenLine,
	Case
		when floor(ART.age) <15 then 'Child'
		when floor(ART.age) >=15 then 'Adult'
	ELSE 'Aii' End as Agegroup,
  b.DATIMAgeGroup,
    ART.age,
   ISTxCurr,

	CASE WHEN cast (weights.weight as float) <20 Then '<20Kgs'
		 WHEN cast (weights.weight as float) >20 and cast (weights.weight as float) <=35 THEN '20-35Kgs'
		 when cast (weights.weight as float) >35  and cast (weights.weight as float) <100 THEN '>35Kgs'
	ELSE 'Not Documented' END AS WeightBands,

	CASE WHEN cast (ART.age as float) <2 THEN '<2 Years'
		 WHEN cast (ART.age as float) between 2 and 4	THEN '2-4 Years'
		 WHEN cast (ART.age as float) between 5 and 9 THEN '5-9 Years'
		 WHEN cast (ART.age as float) between 10 and 14 THEN '10-14 Years'
		ELSE 'Adults' END AS AgeBands 
	 from NDWH.dbo.Linelist_FACTART ART
	INNER JOIN NDWH.dbo.DimAgeGroup b on ART.age=b.Age
    LEFT JOIN ODS.dbo.Intermediate_LastestWeightHeight weights on CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(weights.PatientPK as NVARCHAR(36))), 2) = ART.PatientPK and weights.Sitecode collate Latin1_General_CI_AS =ART.SiteCode collate Latin1_General_CI_AS
   -- LEFT JOIN NDWH.dbo.DimPatient p on ART.PatientPK = p.PatientPK and ART.SiteCode = P.SiteCode


      where IsTXCurr = 1
       ) H 

	Group By SiteCode, FacilityName,County, Subcounty, PartnerName,AgencyName,CurrentRegimen, StartRegimen, Gender, StartARTMonth,StartARTYr,Agegroup ,DATIMAgeGroup,Gender,RegimenLine, WeightBands,AgeBands
	order by SiteCode;

