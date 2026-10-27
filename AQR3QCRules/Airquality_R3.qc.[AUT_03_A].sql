USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[AUT_03_A]
AS

-- Creation date: 27 October 2026
-- QC rule code: AUT_03_A
-- QC rule name: AUT_03_A Vocabulary - [AuthorityRole]
-- QC rule description: The AuthorityRole field in the Authority table should describe the function or responsibility of the authority in the air quality framework. QC should confirm that the reported AuthorityRole exists in the Vocabulary table within the reference data flow.

WITH CTE_valid_authority_roles AS
(
    SELECT DISTINCT
        LTRIM(RTRIM([Notation])) AS AuthorityRole
    FROM [reference].[Vocabulary]
    WHERE [Vocabulary] = 'authorityroles'
      AND NULLIF(LTRIM(RTRIM([Notation])), '') IS NOT NULL
),
CTE_authority AS
(
    SELECT
        [CountryCode],
        [AuthorityInstanceId],
        [AuthorityRole],
        [Email]
    FROM [reporting].[Authority]
    WHERE NULLIF(LTRIM(RTRIM([AuthorityRole])), '') IS NOT NULL
)
SELECT
    a.[CountryCode],
    a.[AuthorityInstanceId],
    a.[AuthorityRole],
    a.[Email]
FROM CTE_authority AS a
WHERE NOT EXISTS
(
    SELECT 1
    FROM CTE_valid_authority_roles AS v
    WHERE v.AuthorityRole = LTRIM(RTRIM(a.[AuthorityRole]))
);
GO