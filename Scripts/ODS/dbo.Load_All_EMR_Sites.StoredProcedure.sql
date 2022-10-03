SELECT
    mfl_interface_db.facilities_facility_info.id,
    mfl_code,
    mfl_interface_db.facilities_facility_info.name As FacilityName,
    mfl_interface_db.facilities_counties.name As County,
    mfl_interface_db.facilities_sub_counties.name As SubCounty,
    facilities_owner.name As Owner,
    lat,
    lon ,
   mfl_interface_db.facilities_partners.name As SDP,
   #type As EMR
   mfl_interface_db.facilities_emr_type.type As EMR,
   facilities_emr_info.status As `EMR Status`,
   facilities_hts_use_type.hts_use_name As `HTS Use`,
   facilities_hts_deployment_type.deployment As `HTS Deployment`,
   facilities_hts_info.status As `HTS Status`,
   facilities_il_info.status as 'IL Status',
   facilities_il_info.webADT_registration as 'registration ie',
   facilities_il_info.webADT_pharmacy as 'pharmacy ie',
   facilities_il_info.Mlab,
   facilities_il_info.Ushauri,
   facilities_mhealth_info.Nishauri,
   facilities_emr_info.ovc,
   facilities_emr_info.otz,
   facilities_emr_info.prep,
   facilities_il_info.three_PM,
   facilities_il_info.air,
   facilities_implementation_type.kp,
   facilities_emr_info.mnch,
   facilities_emr_info.tb,
   facilities_emr_info.lab_manifest
FROM mfl_interface_db.facilities_facility_info
LEFT OUTER JOIN mfl_interface_db.facilities_owner
ON mfl_interface_db.facilities_owner .id = mfl_interface_db.facilities_facility_info .owner_id                       
LEFT OUTER JOIN mfl_interface_db.facilities_counties
ON mfl_interface_db.facilities_counties.id = facilities_facility_info.county_id
LEFT OUTER JOIN mfl_interface_db.facilities_sub_counties
ON mfl_interface_db.facilities_sub_counties.id = facilities_facility_info.sub_county_id
LEFT OUTER JOIN mfl_interface_db.facilities_partners
ON mfl_interface_db.facilities_partners.id= facilities_facility_info.partner_id
LEFT OUTER JOIN mfl_interface_db.facilities_emr_info
ON mfl_interface_db.facilities_facility_info.id= facilities_emr_info.id
LEFT OUTER JOIN mfl_interface_db.facilities_emr_type
ON mfl_interface_db.facilities_emr_info.type_id= facilities_emr_type.id
LEFT OUTER JOIN mfl_interface_db.facilities_hts_info
ON mfl_interface_db.facilities_facility_info.id =  facilities_hts_info.facility_info_id
LEFT OUTER JOIN mfl_interface_db.facilities_hts_use_type
ON mfl_interface_db.facilities_hts_info.hts_use_name_id = facilities_hts_use_type.id
LEFT OUTER JOIN mfl_interface_db.facilities_hts_deployment_type
ON mfl_interface_db.facilities_hts_info.deployment_id = facilities_hts_deployment_type.id
LEFT OUTER JOIN mfl_interface_db.facilities_il_info
ON mfl_interface_db.facilities_il_info.facility_info_id = facilities_facility_info.id
LEFT OUTER JOIN mfl_interface_db.facilities_mhealth_info
ON mfl_interface_db.facilities_mhealth_info.facility_info_id = facilities_facility_info.id
LEFT OUTER JOIN mfl_interface_db.facilities_implementation_type
ON mfl_interface_db.facilities_implementation_type.facility_info_id = facilities_facility_info.id
where facilities_facility_info.approved = True;
