-- ----------------------------
-- procedure structure for generate_consistency_uploads_nw
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[generate_consistency_uploads_nw]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[generate_consistency_uploads_nw]
GO

CREATE PROCEDURE [dbo].[generate_consistency_uploads_nw]
@PERIOD VARCHAR(55),
@docketName VARCHAR(55)
AS
BEGIN
SELECT 
	COUNT(DISTINCT facilityId) AS consistency, 
	docket, 
	county, 
	agency, 
	partner,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, -2, @PERIOD)) + 1, 0) AS startPeriod,
	EOMONTH(@PERIOD) AS endPeriod
FROM (
	SELECT fm.facilityId,
		fm.docketid AS docket,
		f.county,
		f.AgencyName agency,
		f.PartnerName partner
	FROM fact_manifest fm 
		JOIN DWH.dbo.all_EMRSites f ON fm.facilityId = f.MFLCode
	WHERE fm.docketid = @docketName AND fm.timeId BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, -2, @PERIOD)) + 1, 0) AND
	EOMONTH(@PERIOD)
) X
GROUP BY facilityId, docket, county, agency, partner
HAVING COUNT(facilityId) >= 3;
END
GO

