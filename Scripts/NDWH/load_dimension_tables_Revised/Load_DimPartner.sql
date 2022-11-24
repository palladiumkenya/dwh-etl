	MERGE [NDWH].[dbo].[DimPartner] AS a
	USING(SELECT 
			  DISTINCT SDP AS PartnerName
			  FROM HIS_Implementation.dbo.All_EMRSites
		  ) AS b 
	ON(a.PartnerName =b.PartnerName)
	WHEN MATCHED THEN
		UPDATE SET 
		a.partnerName = B.partnerName
	WHEN NOT MATCHED THEN 
		INSERT(PartnerName,LoadDate) VALUES(PartnerName,GETDATE());

	UPDATE  [NDWH].[dbo].[DimPartner]
		SET PartnerName = UPPER(PartnerName)