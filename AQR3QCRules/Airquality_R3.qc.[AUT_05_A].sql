USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[AUT_05_A]
AS

-- Creation date: 27 October 2026
-- QC rule code: AUT_05_A
-- QC rule name: AUT_05_A Vocabulary - [AuthorityInstance]
-- QC rule description: The field AuthorityInstance in the Authority table should contain values representing the level or type of authority entity. QC should confirm that the reported AuthorityInstance exists in the Vocabulary table within the reference data flow.

WITH CTE_valid_authority_instances AS
(
    SELECT DISTINCT
        UPPER(LTRIM(RTRIM([Notation]))) AS AuthorityInstance
    FROM [reference].[Vocabulary]
    WHERE [Vocabulary] = 'authorityinstance'
      AND NULLIF(LTRIM(RTRIM([Notation])), '') IS NOT NULL
),
CTE_authority AS
(
    SELECT
        [CountryCode],
        [AuthorityInstance],
        [AuthorityInstanceId],
        [AuthorityRole],
        [Email],
        NULLIF(LTRIM(RTRIM([AuthorityInstance])), '') AS NormalisedAuthorityInstance
    FROM [reporting].[Authority]
)
SELECT
    a.[CountryCode],
    a.[AuthorityInstance],
    a.[AuthorityInstanceId],
    a.[AuthorityRole],
    a.[Email]
FROM CTE_authority AS a
LEFT JOIN CTE_valid_authority_instances AS v
    ON UPPER(a.NormalisedAuthorityInstance) = v.AuthorityInstance
WHERE a.NormalisedAuthorityInstance IS NULL
   OR v.AuthorityInstance IS NULL;
GO