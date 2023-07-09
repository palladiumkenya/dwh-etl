MERGE [NDWH].[dbo].[DimARTOutcome] AS a
		USING(
				SELECT DISTINCT
					  [ARTOutcome]
					  ,[ARTOutcomeDescription]=
							CASE 
								WHEN [ARTOutcome] ='V'	THEN 'ACTIVE'
								WHEN [ARTOutcome] ='S'	THEN 'STOPPED'
								WHEN [ARTOutcome] ='D'	THEN 'DEAD'
								WHEN [ARTOutcome] ='L'	THEN 'LOSS TO FOLLOW UP'
								WHEN [ARTOutcome] ='NV'	THEN 'NO VISIT'
								WHEN [ARTOutcome] ='T'	THEN 'TRANSFERRED OUT'
								WHEN [ARTOutcome] ='NP' THEN 'NEW PATIENT'
								WHEN [ARTOutcome] ='UL' THEN 'UNDOCUMENTED LOSS'

							END
				  FROM [ODS].[dbo].[Intermediate_ARTOutcomes]
				  WHERE [ARTOutcome] IS NOT NULL AND [ARTOutcome] <>'') AS b 
						ON(
						a.[ARTOutcome] = b.[ARTOutcome]
						  )
		WHEN NOT MATCHED THEN 
						INSERT(ARTOutcome,ARTOutcomeDescription,LoadDate) 
						VALUES(ARTOutcome,ARTOutcomeDescription,GetDate())
		WHEN MATCHED THEN
						UPDATE SET 						
						a.ARTOutcomeDescription =b.ARTOutcomeDescription;