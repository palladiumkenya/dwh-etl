@ECHO OFF
CLS
ECHO You are about to execute the TestPackage SSIS package
PAUSE
Dtexec /f "D:\palladium\dwh-etl\SSIS\PalladiumETL\PalladiumETL\Load_ODS_CT_Tables.dtsx"
PAUSE