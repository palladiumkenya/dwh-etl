with source_relationship_with_patient as (
	select 
		distinct RelationshipWithPatient
	from ODS.dbo.CT_ContactListing
)
select 
    RelationshipWithPatientKey = IDENTITY(INT, 1, 1),
    source_relationship_with_patient.*,
	cast(getdate() as date) as LoadDate
into dbo.DimRelationshipWithPatient
from source_relationship_with_patient
where RelationshipWithPatient is not null and RelationshipWithPatient <> '';

alter table dbo.DimRelationshipWithPatient add primary key(RelationshipWithPatientKey);