MERGE [NDWH].[dbo].[DimHTSTraceType] AS a
		USING	(	SELECT DISTINCT TracingType AS TraceType 
					FROM ODS.dbo.HTS_ClientTracing
					
					UNION

					SELECT DISTINCT TraceType 
					FROM ODS.dbo.HTS_PartnerTracings
				) AS b 
						ON(
							a.TraceType = b.TraceType
						  )
		WHEN NOT MATCHED THEN 
						INSERT(TraceType,LoadDate) 
						VALUES(TraceType,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET	a.TraceType =b.TraceType;