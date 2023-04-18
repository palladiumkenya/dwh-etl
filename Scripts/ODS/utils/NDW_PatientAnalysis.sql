
ALTER PROC NDW_PatientAnalysis
AS
BEGIN
		/*Total DWH Patients X for all programs (CT,HTS,PREP,MNCH) */
		DECLARE @CT_NoOfPatients				INT,
				@HTS_NoOfPatients				INT,
				@PrEP_NoOfPatients				INT,
				@MNCH_NoOfPatients				INT,
				@CT_NoOfPatientsWithNUPI		INT,
				@CT_NoOfPatientsWithoutNUPI		INT,
				@CT_PercentageWithNupi			FLOAT,
				@CT_PercentageWithOutNupi		FLOAT,
				@CT_ActiveNoOfPatients			INT,
				@CT_ActiveNoOfPatientsWithNUPI  FLOAT,
				@CT_ActiveNoOfPatientsWithoutNUPI  FLOAT,
				@CT_ActivePercentageWithNupi		FLOAT,
				@CT_ActivePercentageWithOutNupi		FLOAT

		SELECT DISTINCT @CT_NoOfPatients	= COUNT(1)	FROM ODS.DBO.CT_Patient   ---- Do we factor in the lost,stopped,Died patients?
		SELECT DISTINCT @HTS_NoOfPatients	= COUNT(1)	FROM ODS.DBO.HTS_clients
		SELECT DISTINCT @PrEP_NoOfPatients	=COUNT(1)	FROM ODS.DBO.PrEP_Patient
		SELECT DISTINCT @MNCH_NoOfPatients	=COUNT(1)	FROM ODS.DBO.MNCH_Patient

		---Active number on ART patients

		SELECT @CT_ActiveNoOfPatients = COUNT(1) FROM REPORTING.DBO.Linelist_FACTART
		WHERE ARTOutcome = 'v'

		---END

		SELECT FORMAT(@CT_NoOfPatients,'#,###') CT_NoOfPatients,FORMAT(@HTS_NoOfPatients,'#,###') HTS_NoOfPatients,
			   FORMAT(@PrEP_NoOfPatients,'#,###') PrEP_NoOfPatients,FORMAT(@MNCH_NoOfPatients,'#,###') MNCH_NoOfPatients,
			   FORMAT(@CT_ActiveNoOfPatients,'#,###') CT_ActiveNoOfPatients

		/*CT Total DWH Patients y on % with NUPI */

		SELECT DISTINCT @CT_NoOfPatientsWithNUPI = COUNT(1)		FROM ODS.DBO.CT_Patient
		WHERE NUPI IS NOT NULL   ---- Are they on ART?

		SELECT DISTINCT @CT_NoOfPatientsWithoutNUPI = COUNT(1)		FROM ODS.DBO.CT_Patient
		WHERE Nupi IS NULL

		---ACTIVE WITH AND WITHOUT NUPI
		SELECT @CT_ActiveNoOfPatientsWithNUPI = COUNT(1) FROM REPORTING.DBO.Linelist_FACTART
		WHERE ARTOutcome = 'v' AND NUPI IS NOT NULL

		SELECT @CT_ActiveNoOfPatientsWithoutNUPI = COUNT(1) FROM REPORTING.DBO.Linelist_FACTART
		WHERE ARTOutcome = 'v' AND Nupi IS NULL

		------END

		SELECT FORMAT(@CT_NoOfPatientsWithNUPI,'#,###') CT_NoOfPatientsWithNUPI,FORMAT(@CT_NoOfPatientsWithoutNUPI,'#,###') CT_NoOfPatientsWithoutNUPI,
		FORMAT(@CT_ActiveNoOfPatientsWithNUPI,'#,###') CT_ActiveNoOfPatientsWithNUPI,FORMAT(@CT_ActiveNoOfPatientsWithoutNUPI,'#,###') CT_ActiveNoOfPatientsWithoutNUPI


		SELECT @CT_PercentageWithNupi = ((cast(@CT_NoOfPatientsWithNUPI as float))/(cast(@CT_NoOfPatients as float))) * 100

		SELECT @CT_PercentageWithOutNupi = (( cast(@CT_NoOfPatientsWithoutNUPI as float))/(cast(@CT_NoOfPatients as float))) * 100

		-----ACTIVE % WITH AND WITHOUT NUPI

		SELECT @CT_ActivePercentageWithNupi = ((cast(@CT_ActiveNoOfPatientsWithNUPI as float))/(cast(@CT_ActiveNoOfPatients as float))) * 100

		SELECT @CT_ActivePercentageWithOutNupi = (( cast(@CT_ActiveNoOfPatientsWithoutNUPI as float))/(cast(@CT_ActiveNoOfPatients as float))) * 100

		---- END 

		SELECT @CT_PercentageWithNupi CT_PercentageWithNupi,@CT_PercentageWithOutNupi CT_PercentageWithOutNupi,

		@CT_ActivePercentageWithNupi CT_ActivePercentageWithNupi,@CT_ActivePercentageWithOutNupi CT_ActivePercentageWithOutNupi
END
GO
EXEC NDW_PatientAnalysis



