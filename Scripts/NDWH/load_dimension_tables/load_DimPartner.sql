---DimPartner Load
with source_partner as (
select
	distinct SDP as PartnerName
from HIS_Implementation.dbo.All_EMRSites
)
select 
	PartnerKey = IDENTITY(INT, 1, 1),
	source_partner.*,
	cast(getdate() as date) as LoadDate
into dbo.DimPartner
from source_partner;
ALTER TABLE dbo.DimPartner ADD PRIMARY KEY(PartnerKey);