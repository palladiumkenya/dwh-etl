--DimAgency Load
with source_agency as (
select 
	distinct [SDP Agency] as PartnerName
from HIS_Implementation.dbo.All_EMRSites
where [SDP Agency] <> 'NULL'
)
select
	AgencyKey = IDENTITY(INT, 1, 1),
	source_agency.*,
	cast(getdate() as date) as LoadDate
into NDWH.dbo.DimAgency
from source_agency;

ALTER TABLE NDWH.dbo.DimAgency ADD PRIMARY KEY(AgencyKey);