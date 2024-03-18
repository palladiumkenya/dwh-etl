MERGE [NDWH].[dbo].[DimHTSTraceOutcome] AS a
		USING	(	SELECT DISTINCT 
							CASE 
									WHEN TracingOutcome ='Contacted and not Reached'	THEN 'Contact Not Reached'
									WHEN TracingOutcome ='Contact Not Reached'			THEN 'Contact Not Reached'
								ELSE TracingOutcome
							END
						AS TraceOutcome
					FROM ODS.dbo.HTS_ClientTracing 
					WHERE  TracingOutcome <> 'null' AND TracingOutcome <> '' AND TracingOutcome IS NOT NULL
				
					UNION

					SELECT DISTINCT
							CASE 
									WHEN TraceOutcome ='Contacted and not Reached' THEN 'Contact Not Reached'
									WHEN TraceOutcome ='Contact Not Reached'		THEN 'Contact Not Reached'
								ELSE TraceOutcome
							END AS TraceOutcome					
					FROM ODS.dbo.HTS_PartnerTracings
					WHERE  TraceOutcome <> 'null' AND TraceOutcome <> ''AND TraceOutcome IS NOT NULL
				) AS b 
						ON(
							a.[TraceOutcome] = b.[TraceOutcome]
						  )
		WHEN NOT MATCHED THEN 
						INSERT([TraceOutcome],LoadDate) 
						VALUES([TraceOutcome],GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.[TraceOutcome] =b.[TraceOutcome];
		
