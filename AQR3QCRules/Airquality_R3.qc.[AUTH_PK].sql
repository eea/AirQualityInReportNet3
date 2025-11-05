USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[AUTH_PK] AS

-- Creation date: 29 August 2025
-- QC rule code: AUTH_PK
-- QC rule name: AUTH_PK Constraint - [CountryCode,AuthorityInstanceId,Object,Email]

WITH CTE_authority AS (
  SELECT 
    /*record_id,*/ 
    NULLIF("AuthorityInstanceId", '') AS AuthorityInstanceId,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("Object", '') AS Object,
    NULLIF("Email", '') AS Email
  FROM reporting."authority"
),
duplicate_auth_records AS (
  SELECT 
    AuthorityInstanceId,
    CountryCode,
    Object,
    Email
  FROM CTE_authority 
  GROUP BY AuthorityInstanceId, CountryCode, Object, Email
  HAVING COUNT(*) > 1
)
SELECT 
 /* a.record_id,*/a.AuthorityInstanceId,a.CountryCode,a.Object,a.Email
FROM CTE_authority a
LEFT JOIN duplicate_auth_records d
  ON a.AuthorityInstanceId = d.AuthorityInstanceId
 AND a.CountryCode = d.CountryCode
 AND a.Object = d.Object 
 AND a.Email = d.Email
WHERE d.AuthorityInstanceId IS NOT NULL  -- duplicity
   OR a.AuthorityInstanceId IS NULL 
   OR a.CountryCode IS NULL
   OR a.Object IS NULL
   OR a.Email IS NULL