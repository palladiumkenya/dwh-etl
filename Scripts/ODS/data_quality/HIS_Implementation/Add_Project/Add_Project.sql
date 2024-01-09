
IF NOT EXISTS (  SELECT * FROM   HIS_Implementation.sys.columns WHERE  object_id = OBJECT_ID(N'HIS_Implementation.dbo.All_EMRSites') AND name = 'Project')
		BEGIN
			ALTER TABLE HIS_Implementation.dbo.All_EMRSites
			ADD Project varchar(100);
		END

