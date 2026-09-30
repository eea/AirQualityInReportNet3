USE [Airquality_R3];
GO

/* ============================================================
   ZOG_02_B

   Returns records from reporting.ZoneGeometry whose ZoneId does
   NOT follow the recommended naming convention:

       ZON{separator}{CountryCode}[optional suffix]

   Allowed separators: '.', '_' or '-'.

   Valid examples for CountryCode = ES:
       ZON_ES
       ZON-ES
       ZON.ES
       ZON_ES0835
   ============================================================ */
CREATE OR ALTER VIEW [qc].[ZOG_02_B]
AS
WITH CTE_Zone AS
(
    SELECT
        /* Keep the original value to identify leading/trailing spaces. */
        zg.ZoneId AS ZoneIdRaw,

        /* Trim ZoneId; convert an empty value to NULL. */
        NULLIF(LTRIM(RTRIM(zg.ZoneId)), '') AS ZoneId,

        /* Trim CountryCode; convert an empty value to NULL. */
        NULLIF(LTRIM(RTRIM(zg.CountryCode)), '') AS CountryCode,

        /* Identify ZoneId values with leading or trailing spaces. */
        CASE
            WHEN zg.ZoneId IS NULL THEN 0
            WHEN zg.ZoneId <> LTRIM(RTRIM(zg.ZoneId)) THEN 1
            ELSE 0
        END AS HasLeadingOrTrailingSpaces
    FROM [reporting].[ZoneGeometry] AS zg
),
CTE_Countries AS
(
    /* Use the reference vocabulary as the canonical ISO country-code source. */
    SELECT DISTINCT
        UPPER(LTRIM(RTRIM(v.Notation))) AS CountryCode
    FROM [reference].[Vocabulary] AS v
    WHERE v.Vocabulary = 'countries'
      AND NULLIF(LTRIM(RTRIM(v.Notation)), '') IS NOT NULL
)
SELECT
    z.ZoneId,
    z.CountryCode
FROM CTE_Zone AS z
WHERE
    /* ZoneId is missing, empty, or has leading/trailing spaces. */
    z.ZoneIdRaw IS NULL
    OR z.ZoneId IS NULL
    OR z.HasLeadingOrTrailingSpaces = 1

    /* CountryCode is missing. */
    OR z.CountryCode IS NULL

    /* CountryCode does not exist in the reference vocabulary. */
    OR NOT EXISTS
    (
        SELECT 1
        FROM CTE_Countries AS c
        WHERE c.CountryCode COLLATE Latin1_General_BIN2 =
              z.CountryCode COLLATE Latin1_General_BIN2
    )

    /* ZoneId does not comply with ZON{separator}{CountryCode}[optional suffix]. */
    OR NOT
    (
        /* Minimum length: ZON + separator + CountryCode. */
        LEN(z.ZoneId) >= 6

        /* Prefix must be exactly ZON and is case-sensitive. */
        AND LEFT(z.ZoneId COLLATE Latin1_General_BIN2, 3) = 'ZON'

        /* The separator must be '.', '_' or '-'. */
        AND SUBSTRING(z.ZoneId, 4, 1) IN ('.', '_', '-')

        /* The embedded CountryCode must contain two uppercase letters. */
        AND SUBSTRING(z.ZoneId COLLATE Latin1_General_BIN2, 5, 2)
            LIKE '[A-Z][A-Z]'

        /* The embedded CountryCode must match the reported CountryCode. */
        AND SUBSTRING(z.ZoneId COLLATE Latin1_General_BIN2, 5, 2) =
            z.CountryCode COLLATE Latin1_General_BIN2
    );