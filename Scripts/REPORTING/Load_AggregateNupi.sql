BEGIN
			
	IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateNupi]', N'U') IS NOT NULL 
		DROP TABLE [REPORTING].[dbo].[AggregateNupi];
			
			SELECT
			SiteCode,
			FacilityName,
			County,
			Subcounty,
			PartnerName,
			AgencyName,
			Gender,
			AgeGroup,
			sum(case when age between 0 and 18  then 1 else 0 end) as Children,
			sum(case when age >18   then 1 else 0 end) as Adults,
			COUNT (NUPI)AS NumNUPI
			INTO [REPORTING].[dbo].[AggregateNupi]
			FROM [REPORTING].[dbo].[Linelist_FACTART]
			WHERE ARTOutcomeDescription ='Active' and NUPI is not null-- and age between 0 and 120
			GROUP BY
			SiteCode,
			FacilityName,
			County,
			Subcounty,
			PartnerName,
			AgencyName,
			Gender,
			AgeGroup
					
	END
