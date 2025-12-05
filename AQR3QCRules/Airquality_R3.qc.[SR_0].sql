USE [Airquality_R3]
GO

/****** Object:  View [qc].[SR_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SR_0] AS

-- Creation date: 27 November 2025
-- QC rule code: SR_0
-- QC rule name: SR_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(SR_Id, '') AS SR_Id,
    NULLIF(SR_ApplicationId, '') AS SR_ApplicationId,
    SR_Application,
    ResultEncoding,
    SR_AssessmentMethodId,
	Deletion

  FROM reporting.SpatialRepresentativeness
),

cte_reference AS (
  SELECT
    CountryCode,
    SR_Id,
    SR_ApplicationId,
    SR_Application,
    ResultEncoding,
    SR_AssessmentMethodId,
    Deletion

  FROM reference.SpatialRepresentativeness
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.SR_Id,
  s.SR_ApplicationId,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.SR_Application, '') = COALESCE(r.SR_Application, '')
     AND COALESCE(s.ResultEncoding, '') = COALESCE(r.ResultEncoding, '')
     AND COALESCE(s.SR_AssessmentMethodId, '') = COALESCE(r.SR_AssessmentMethodId, '')
     AND COALESCE(s.SR_ApplicationId, '') = COALESCE(r.SR_ApplicationId, '')
     AND COALESCE(s.SR_Id, '') = COALESCE(r.SR_Id, '')
     AND COALESCE(s.CountryCode, '') = COALESCE(r.CountryCode, '')
     AND COALESCE(s.Deletion, '') = COALESCE(r.Deletion, '')
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status
FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.SR_Id = r.SR_Id
 AND s.SR_ApplicationId = r.SR_ApplicationId

GO
