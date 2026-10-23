USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUT_02_A]    Script Date: 23/10/2026 12:15:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[AUT_02_A]
AS

-- Creation date: 21 October 2026
-- QC rule code: AUT_02_A
-- QC rule name: AUT_02_A Cross-check - [AuthorityInstanceId]
-- QC rule description: The value reported under AuthorityInstanceId in the Authority table must satisfy conformity with the expected reference ID based on the associated AuthorityInstance type: If AuthorityInstance = 'nuts0' (id), then AuthorityInstanceId must match CountryCode in the same Authority table (AUT_01) [Notation]; If AuthorityInstance = 'nuts1-3' (id), then AuthorityInstanceId must match an existing ZoneId in the AssessmentRegimeZone table (ARZ_05) [Notation]; If AuthorityInstance = 'zone', then AuthorityInstanceId must match an existing ZoneId in the ZoneGeometry table (ZOG_02) [Notation]. See relationship between id and notation in https://dd.eionet.europa.eu/vocabulary/aq/authorityinstance

WITH CTE_authority AS
(
    SELECT
        LTRIM(RTRIM(NULLIF([AuthorityInstance], ''))) AS AuthorityInstance,
        LTRIM(RTRIM(NULLIF([AuthorityInstanceId], ''))) AS AuthorityInstanceId,
        LTRIM(RTRIM(NULLIF([CountryCode], ''))) AS CountryCode
    FROM [reporting].[Authority]
    WHERE NULLIF(LTRIM(RTRIM([AuthorityInstance])), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM([AuthorityInstanceId])), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM([CountryCode])), '') IS NOT NULL
),

-- Valid ZoneId values reported in AssessmentRegimeZone.
CTE_assessment_regime_zones AS
(
    SELECT DISTINCT
        LTRIM(RTRIM(NULLIF([ZoneId], ''))) AS ZoneId
    FROM [reporting].[AssessmentRegimeZone]
    WHERE NULLIF(LTRIM(RTRIM([ZoneId])), '') IS NOT NULL
),

-- Valid ZoneId values reported in ZoneGeometry.
CTE_zone_geometries AS
(
    SELECT DISTINCT
        LTRIM(RTRIM(NULLIF([ZoneId], ''))) AS ZoneId
    FROM [reporting].[ZoneGeometry]
    WHERE NULLIF(LTRIM(RTRIM([ZoneId])), '') IS NOT NULL
),

-- AUT_01: for AuthorityInstance = nuts0, AuthorityInstanceId
-- must match CountryCode in the same Authority record.
CTE_invalid_nuts0 AS
(
    SELECT *
    FROM CTE_authority
    WHERE AuthorityInstance = 'nuts0'
      AND AuthorityInstanceId <> CountryCode
),

-- ARZ_05: for AuthorityInstance = nuts1, nuts2 or nuts3,
-- AuthorityInstanceId must match a reported AssessmentRegimeZone ZoneId.
CTE_invalid_nuts1_to_nuts3 AS
(
    SELECT a.*
    FROM CTE_authority AS a
    WHERE a.AuthorityInstance IN ('nuts1', 'nuts2', 'nuts3')
      AND NOT EXISTS
      (
          SELECT 1
          FROM CTE_assessment_regime_zones AS arz
          WHERE arz.ZoneId = a.AuthorityInstanceId
      )
),

-- ZOG_02: for AuthorityInstance = zone, AuthorityInstanceId
-- must match a reported ZoneGeometry ZoneId.
CTE_invalid_zone AS
(
    SELECT a.*
    FROM CTE_authority AS a
    WHERE a.AuthorityInstance = 'zone'
      AND NOT EXISTS
      (
          SELECT 1
          FROM CTE_zone_geometries AS zog
          WHERE zog.ZoneId = a.AuthorityInstanceId
      )
)

SELECT
    'AUT_01' AS RuleViolation,
    AuthorityInstance,
    AuthorityInstanceId,
    CountryCode
FROM CTE_invalid_nuts0

UNION ALL

SELECT
    'ARZ_05' AS RuleViolation,
    AuthorityInstance,
    AuthorityInstanceId,
    CountryCode
FROM CTE_invalid_nuts1_to_nuts3

UNION ALL

SELECT
    'ZOG_02' AS RuleViolation,
    AuthorityInstance,
    AuthorityInstanceId,
    CountryCode
FROM CTE_invalid_zone;
GO


