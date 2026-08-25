USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_02_B]    Script Date: 25/08/2026 12:20:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[ZOG_02_B] AS 
-- Return zone records that DO NOT comply with the exact naming convention: ZON{sep}{CC} 
-- where: --   - prefix is exactly 'ZON' (case-sensitive), 
--   - separator is exactly one of '.', '_' or '-', --   - country code (CC) is exactly two uppercase letters, 
--   - CC must exist in reference.Vocabulary (vocabulary = 'countries'). 
-- Also treat NULL, empty, or values with leading/trailing spaces as invalid. 
WITH CTE_zone AS ( SELECT 
-- keep raw value to detect leading/trailing spaces 
[ZoneId] AS [ZoneIdRaw],
-- normalized (trimmed) ZoneId; empty string becomes NULL
    NULLIF(LTRIM(RTRIM([ZoneId])) COLLATE DATABASE_DEFAULT, '') AS [ZoneId],

    -- normalized (trimmed) CountryCode from source table (preserve original column selection)
    NULLIF(LTRIM(RTRIM([CountryCode])) COLLATE DATABASE_DEFAULT, '') AS [CountryCode],

    -- flag if original value contained leading/trailing spaces (or differs after trimming)
    CASE
        WHEN [ZoneId] IS NULL THEN 1
        WHEN LTRIM(RTRIM([ZoneId])) <> [ZoneId] THEN 1
        ELSE 0
    END AS [HasLeadingOrTrailingSpaces]
FROM [reporting].[ZoneGeometry]
), CTE_countries AS ( 
-- use reference.Vocabulary as canonical ISO 3166-1 alpha-2 source (uppercased) 
SELECT DISTINCT UPPER(LTRIM(RTRIM([Notation])) COLLATE DATABASE_DEFAULT) AS [CountryCode] 
FROM [reference].[Vocabulary] 
WHERE [vocabulary] COLLATE DATABASE_DEFAULT = 'countries' AND NULLIF(LTRIM(RTRIM([Notation])) COLLATE DATABASE_DEFAULT, '') IS NOT NULL ) 
SELECT z.[ZoneId], z.[CountryCode] FROM CTE_zone AS z WHERE 
-- 1) NULL or empty after t[qc].[STA_PK]rimming -> invalid 
z.[ZoneIdRaw] IS NULL OR z.[ZoneId] IS NULL
-- 2) leading/trailing spaces detected -> invalid
OR z.[HasLeadingOrTrailingSpaces] = 1

-- 3) otherwise require exact valid format; if not valid, return the row
OR NOT (
    -- must be exactly length 6: 'Z' 'O' 'N' sep C C  (3 + 1 + 2 = 6)
    LEN(z.[ZoneId]) = 6

    -- enforce case-sensitivity for prefix and country letters using a binary collation
    AND LEFT(z.[ZoneId] COLLATE Latin1_General_BIN2, 3) = 'ZON'

    -- separator must be exactly one of '.', '_' or '-'
    AND SUBSTRING(z.[ZoneId], 4, 1) IN ('.', '_', '-')

    -- country code portion must be two uppercase A-Z letters (binary, case-sensitive)
    AND SUBSTRING(z.[ZoneId] COLLATE Latin1_General_BIN2, 5, 2) LIKE '[A-Z][A-Z]'

    -- country code must exist in the reference country list (compare using binary collation)
    AND EXISTS (
        SELECT 1
        FROM CTE_countries AS c
        WHERE c.[CountryCode] COLLATE Latin1_General_BIN2 =
              SUBSTRING(z.[ZoneId] COLLATE Latin1_General_BIN2, 5, 2)
    )
);
GO


