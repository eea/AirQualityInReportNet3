USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_02_A]    Script Date: 25/08/2026 14:12:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create VIEW [qc].[ZOG_02_A] AS
WITH CTE_src AS (
  SELECT
    [CountryCode]        AS CountryCodeRaw,
    [ZoneId]             AS ZoneIdRaw,
    NULLIF(LTRIM(RTRIM([ZoneId])), '')       AS ZoneIdNorm,
    NULLIF(LTRIM(RTRIM([CountryCode])), '')  AS CountryCodeNorm,
    CASE WHEN [ZoneId] IS NOT NULL AND LTRIM(RTRIM([ZoneId])) <> [ZoneId] THEN 1 ELSE 0 END
      AS HasLeadingOrTrailingSpaces
  FROM [reporting].[ZoneGeometry]
),
CTE_dups AS (
  -- duplicates on normalized (trimmed) ZoneId per normalized CountryCode
  SELECT CountryCodeNorm, ZoneIdNorm
  FROM CTE_src
  WHERE ZoneIdNorm IS NOT NULL
  GROUP BY CountryCodeNorm, ZoneIdNorm
  HAVING COUNT(*) > 1
)
SELECT
  s.ZoneIdRaw   AS [ZoneId],
  s.CountryCodeRaw AS [CountryCode],
  s.ZoneIdNorm  AS [ZoneId_Normalized],
  s.HasLeadingOrTrailingSpaces,
  CASE
    WHEN s.ZoneIdNorm IS NULL THEN 'MISSING_OR_EMPTY'
    WHEN s.HasLeadingOrTrailingSpaces = 1 THEN 'LEADING_OR_TRAILING_SPACES'
    WHEN d.ZoneIdNorm IS NOT NULL THEN 'DUPLICATE'
    ELSE 'UNKNOWN'
  END AS [QC_FailureReason]
FROM CTE_src s
LEFT JOIN CTE_dups d
  ON d.CountryCodeNorm = s.CountryCodeNorm
  AND d.ZoneIdNorm = s.ZoneIdNorm
WHERE
  s.ZoneIdNorm IS NULL
  OR s.HasLeadingOrTrailingSpaces = 1
  OR d.ZoneIdNorm IS NOT NULL;

GO


