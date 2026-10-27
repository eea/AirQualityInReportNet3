USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[AUT_10_A]
AS

-- Creation date: 27 October 2026
-- QC rule code: AUT_10_A
-- QC rule name: AUT_10_A Vocabulary - [AuthorityStatus]
-- QC rule description: The AuthorityStatus field in the Authority table should indicate whether the authority is currently operational. QC should confirm that the reported AuthorityStatus exists in the Vocabulary table within the reference data flow.

WITH CTE_valid_authority_statuses AS
(
    SELECT DISTINCT
        UPPER(LTRIM(RTRIM([Notation]))) AS AuthorityStatus
    FROM [reference].[Vocabulary]
    WHERE [Vocabulary] = 'authoritystatus'
      AND NULLIF(LTRIM(RTRIM([Notation])), '') IS NOT NULL
),
CTE_authority AS
(
    SELECT
        [CountryCode],
        [AuthorityInstanceId],
        [AuthorityRole],
        [Email],
        [AuthorityStatus],
        NULLIF(LTRIM(RTRIM([AuthorityStatus])), '') AS NormalisedAuthorityStatus
    FROM [reporting].[Authority]
)
SELECT
    a.[CountryCode],
    a.[AuthorityInstanceId],
    a.[AuthorityRole],
    a.[Email],
    a.[AuthorityStatus]
FROM CTE_authority AS a
LEFT JOIN CTE_valid_authority_statuses AS v
    ON UPPER(a.NormalisedAuthorityStatus) = v.AuthorityStatus
WHERE a.NormalisedAuthorityStatus IS NULL
   OR v.AuthorityStatus IS NULL;
GO