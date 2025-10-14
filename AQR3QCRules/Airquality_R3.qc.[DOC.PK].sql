USE [Airquality_R3]
GO

/****** Object:  View [qc].[DOC.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[DOC.PK] AS

-- Creation date: 22 September 2025
-- QC rule code: DOC.PK
-- QC rule name: DOC.PK Constraint - [CountryCode,DataTable,DocumentObject,DocumentId]

WITH CTE_Doc AS (
  SELECT 
    /*record_id,*/
    NULLIF("DataTable", '') AS DataTable   ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("DocumentObject", '') AS DocumentObject, 
	NULLIF("DocumentId", '') AS DocumentId
	
	
  FROM reporting.Documentation
),
duplicate_auth_records AS (
  SELECT 
    DataTable ,
    CountryCode,
    DocumentObject,
	DocumentId
  FROM CTE_Doc 
  GROUP BY DataTable , CountryCode,DocumentObject,DocumentId
	
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.DataTable ,a.CountryCode,a.DocumentObject,a.DocumentId
	
	FROM CTE_Doc a
	LEFT JOIN duplicate_auth_records d
	  ON a.DataTable  = d.DataTable 
	 AND a.CountryCode = d.CountryCode
	 AND a.DocumentObject = d.DocumentObject
	 AND a.DocumentId=a.DocumentId
 
 
	WHERE d.CountryCode  IS NOT NULL  -- duplicity
	   OR a.CountryCode  IS NULL 
	   OR a.DataTable IS NULL
	   OR a.DocumentObject IS NULL
	   OR a.DocumentId IS NULL


GO


