USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_PK]
AS

-- QC rule code: SPO_PK
-- QC rule name: SPO_PK Constraint - [CountryCode,AssessmentMethodId]
-- QC rule description: The quality control shall verify that each record reported in the SamplingPoint table is uniquely identified by the combination of CountryCode and AssessmentMethodId. None of the primary key attributes shall be null and no two records shall share the same combination of primary key values.

WITH CTE_SPO AS (
    SELECT
        NULLIF("CountryCode", '') AS CountryCode,
        NULLIF("AssessmentMethodId", '') AS AssessmentMethodId
    FROM reporting."samplingpoint"
),
duplicate_spo_records AS (
    SELECT
        CountryCode,
        AssessmentMethodId
    FROM CTE_SPO
    GROUP BY
        CountryCode,
        AssessmentMethodId
    HAVING COUNT(*) > 1
)
SELECT
    a.CountryCode,
    a.AssessmentMethodId
FROM CTE_SPO AS a
LEFT JOIN duplicate_spo_records AS d
    ON a.CountryCode = d.CountryCode
   AND a.AssessmentMethodId = d.AssessmentMethodId
WHERE d.CountryCode IS NOT NULL
   OR a.CountryCode IS NULL
   OR a.AssessmentMethodId IS NULL
GO