USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUT_PK]    Script Date: 20/10/2026 13:17:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* ============================================================
   QC rule code: AUT_PK
   QC rule name: AUT_PK Constraint
   QC rule description: Primary key uniqueness validation
   Primary key: CountryCode, AuthorityInstanceId, AuthorityRole, Email
   ============================================================ */

CREATE   VIEW [qc].[AUT_PK]
AS
WITH CTE_authority AS
(
    SELECT
        NULLIF([CountryCode], '')         AS CountryCode,
        NULLIF([AuthorityInstanceId], '') AS AuthorityInstanceId,
        NULLIF([AuthorityRole], '')       AS AuthorityRole,
        NULLIF([Email], '')               AS Email
    FROM [reporting].[authority]
),
duplicate_auth_records AS
(
    SELECT
        CountryCode,
        AuthorityInstanceId,
        AuthorityRole,
        Email
    FROM CTE_authority
    GROUP BY
        CountryCode,
        AuthorityInstanceId,
        AuthorityRole,
        Email
    HAVING COUNT(*) > 1
)
SELECT
/*record_id*/
    a.CountryCode,
    a.AuthorityInstanceId,
    a.AuthorityRole,
    a.Email
FROM CTE_authority AS a
LEFT JOIN duplicate_auth_records AS d
    ON  a.CountryCode = d.CountryCode
    AND a.AuthorityInstanceId = d.AuthorityInstanceId
    AND a.AuthorityRole = d.AuthorityRole
    AND a.Email = d.Email
WHERE
       d.CountryCode IS NOT NULL
    OR a.CountryCode IS NULL
    OR a.AuthorityInstanceId IS NULL
    OR a.AuthorityRole IS NULL
    OR a.Email IS NULL;
GO


