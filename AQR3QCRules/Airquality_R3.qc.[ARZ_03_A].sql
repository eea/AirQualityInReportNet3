USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_03_A]    Script Date: 02/10/2026 13:09:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_03_A]
AS
/* ============================================================
   QC rule code: ARZ_03_A
   QC rule name: Referential validation - ZoneId

   Validation logic:
   - ZoneCategory = 'aqzone':
     ZoneId must exist in reporting.ZoneGeometry or
     reference.ZoneGeometry for the same CountryCode.

   - ZoneCategory = 'nuts':
     ZoneId must exist in reference.AdminBoundaryLookup in one
     of the level0_code to level3_code columns for the same
     CountryCode (matched to AdminBoundaryLookup.ICC).

   ZoneId missing-value validation is out of scope.
   ============================================================ */

WITH CTE_assessment_regime_zone AS
(
    SELECT
        CONVERT(NVARCHAR(100), arz.CountryCode)
            COLLATE Latin1_General_100_CI_AS AS CountryCodeRaw,

        CONVERT(NVARCHAR(500), arz.AssessmentRegimeId)
            COLLATE Latin1_General_100_CI_AS AS AssessmentRegimeId,

        CONVERT(NVARCHAR(500), arz.ZoneId)
            COLLATE Latin1_General_100_CI_AS AS ZoneIdRaw,

        CONVERT(NVARCHAR(100), arz.ZoneCategory)
            COLLATE Latin1_General_100_CI_AS AS ZoneCategoryRaw,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), arz.CountryCode))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), arz.ZoneId))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneId,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), arz.ZoneCategory))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneCategory
    FROM [reporting].[AssessmentRegimeZone] AS arz
),
CTE_available_aqzones AS
(
    /* Zones in the current R3 submission. */
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), zg.CountryCode))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), zg.ZoneId))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneId
    FROM [reporting].[ZoneGeometry] AS zg

    UNION

    /* Zones in the reference dataset. */
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), zg.CountryCode))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), zg.ZoneId))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneId
    FROM [reference].[ZoneGeometry] AS zg
),
CTE_available_nuts AS
(
    /*
      Transform level0_code to level3_code into rows using UNION.
      This avoids CROSS APPLY and is more portable to Dremio.
    */

    SELECT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), abl.ICC))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), abl.level0_code))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneId
    FROM [reference].[AdminBoundaryLookup] AS abl

    UNION

    SELECT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), abl.ICC))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), abl.level1_code))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneId
    FROM [reference].[AdminBoundaryLookup] AS abl

    UNION

    SELECT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), abl.ICC))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), abl.level2_code))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneId
    FROM [reference].[AdminBoundaryLookup] AS abl

    UNION

    SELECT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), abl.ICC))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), abl.level3_code))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS ZoneId
    FROM [reference].[AdminBoundaryLookup] AS abl
)
SELECT
    arz.CountryCodeRaw AS CountryCode,
    arz.AssessmentRegimeId,
    arz.ZoneIdRaw AS ZoneId,
    arz.ZoneCategoryRaw AS ZoneCategory,
    CASE
        WHEN arz.ZoneCategory = N'nuts'
            THEN 'NUTS_ZONEID_NOT_FOUND_IN_ADMINBOUNDARYLOOKUP'
        WHEN arz.ZoneCategory = N'aqzone'
            THEN 'AQZONE_ZONEID_NOT_FOUND_IN_CURRENT_OR_REFERENCE_ZONEGEOMETRY'
    END AS QC_FailureReason
FROM CTE_assessment_regime_zone AS arz
LEFT JOIN CTE_available_aqzones AS aqz
    ON  arz.ZoneCategory = N'aqzone'
    AND aqz.CountryCode = arz.CountryCode
    AND aqz.ZoneId = arz.ZoneId
LEFT JOIN CTE_available_nuts AS nuts
    ON  arz.ZoneCategory = N'nuts'
    AND nuts.CountryCode = arz.CountryCode
    AND nuts.ZoneId = arz.ZoneId
WHERE arz.ZoneId IS NOT NULL
  AND
  (
      (arz.ZoneCategory = N'aqzone' AND aqz.ZoneId IS NULL)
      OR
      (arz.ZoneCategory = N'nuts' AND nuts.ZoneId IS NULL)
  );
GO


