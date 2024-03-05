MERGE [NDWH].[dbo].[DimHTSTraceOutcome] AS a
		USING	(	SELECT DISTINCT TracingOutcome AS TraceOutcome
					FROM ODS.dbo.HTS_ClientTracing 
					WHERE  TracingOutcome <> 'null' AND TracingOutcome <> ''
				
					UNION

					SELECT DISTINCT TraceOutcome 
					FROM ODS.dbo.HTS_PartnerTracings
					WHERE  TraceOutcome <> 'null' AND TraceOutcome <> ''
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
		
		UPDATE source_data
			SET [TraceOutcome]=	CASE
									WHEN source_data.TraceOutcome IN ('Contact Not Reached', 'Contacted and not Reached') THEN 'Contact Not Reached'
									ELSE source_data.TraceOutcome
								END 
		FROM [NDWH].[dbo].[DimHTSTraceOutcome] source_data;

		with cte AS (
						Select
						TraceOutcome,
						

						 ROW_NUMBER() OVER (PARTITION BY TraceOutcome ORDER BY
						TraceOutcome) Row_Num
						FROM NDWH.dbo.DimHTSTraceOutcome(NoLock)
						)
						DELETE from cte 
						Where Row_Num >1 ;

