USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUTH_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[AUTH_0] AS

-- Creation date: 27 November 2025
-- QC rule code: AUTH_0
-- QC rule name: AUTH_0 Status - [PK]


WITH cte_submitted AS (
  SELECT 
    -- record_id,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("AuthorityInstanceId", '') AS AuthorityInstanceId,
    NULLIF("Object", '') AS Object,
    NULLIF("Email", '') AS Email,
    NULLIF("AuthorityInstance", '') AS AuthorityInstance,
    NULLIF("AuthorityStatus", '') AS AuthorityStatus,
    NULLIF("OrganisationURL", '') AS OrganisationURL
  FROM reporting."Authority"
),

cte_reference AS (
  SELECT
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("AuthorityInstanceId", '') AS AuthorityInstanceId,
    NULLIF("Object", '') AS Object,
    NULLIF("Email", '') AS Email,
    NULLIF("OrganisationURL", '') AS OrganisationURL,
    NULLIF("Deletion", '') AS Deletion,
    NULLIF("ReportingTime", '') AS ReportingTime
  FROM reference."Authority"
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AuthorityInstanceId,
  s.Object,
  s.Email,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.OrganisationURL, '') = COALESCE(r.OrganisationURL, '')
      THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status
FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AuthorityInstanceId = r.AuthorityInstanceId
 AND s.Object = r.Object
 AND s.Email = r.Email

GO
