BEGIN TRAN
SELECT TOP 10  
	   CAST(CAST([Ticket Number] AS nvarchar(50)) as INT) As TicketNumber
      ,CAST([Summary] AS nvarchar(100))As Summary
      ,CAST([Description]  AS nvarchar(max))As [Description]
      ,CAST([Assigned To]  AS nvarchar(100))As AssignedTo
      ,CAST([Category] AS nvarchar(100))As Category
      ,CAST([Closed On]  AS nvarchar(100))As ClosedOn
      ,CAST([Created On] AS nvarchar(100))As CreatedOn
      ,CAST([Due On] AS nvarchar(100))As DueOn
      ,CAST([Priority] AS nvarchar(100))As [Priority] ---
      ,CAST([Organization Name] AS nvarchar(100))As OrganizationName
      ,CAST([Status] AS nvarchar(100))As [Status]
      ,CAST([Time Spent] AS nvarchar(100))As TimeSpent
      ,CAST([Time To Resolve] AS nvarchar(100))As TimeToResolve
      ,CAST([Organization Host] AS nvarchar(100))As OrganizationHost
      ,CAST([Link to Ticket] AS nvarchar(100))As LinkToTicket
      ,CAST([Service Delivery Patner]  AS nvarchar(100))As ServiceDeliveryPatner
      ,CAST([SDP Point Person Tagged?]   AS nvarchar(100))As SDPPointPersonTagged
      ,CAST([User's Facility Organization]   AS nvarchar(100))As UserFacilityOrganization
      ,CAST([Due Date]   AS nvarchar(100))As DueDate
      ,CAST([Target Version]   AS nvarchar(100))As TargetVersion
      ,CAST([Solution]    AS nvarchar(100))As Solution
      ,CAST([County]    AS nvarchar(100))As County  
      ,CAST([Issue Type]   AS nvarchar(100))As IssueType
      ,CAST([Resolution Status]   AS nvarchar(100))As ResolutionStatus
	  INTO REPORTING.dbo.LinelistTicketExport
  FROM [ODS].[dbo].[OLE DB Destination]

  SELECT * FROM REPORTING.dbo.LinelistTicketExport

  ROLLBACK TRAN