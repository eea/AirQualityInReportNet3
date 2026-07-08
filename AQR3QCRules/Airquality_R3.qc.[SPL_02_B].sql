USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_02_B] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_02_B_TEST]
AS

WITH CTE_samplingProcess AS
(
    SELECT
        NULLIF(LTRIM(RTRIM(CountryCode)), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM(AssessmentMethodId)), '') AS AssessmentMethodId
    FROM reporting.SamplingPointLocation
),

missing_assessmentMethod AS
(
    SELECT
        sp.CountryCode,
        sp.AssessmentMethodId
    FROM CTE_samplingProcess sp

    LEFT JOIN reporting.SamplingPoint spo
        ON sp.CountryCode = spo.CountryCode
       AND sp.AssessmentMethodId = spo.AssessmentMethodId

    WHERE
        sp.AssessmentMethodId IS NOT NULL
        AND spo.AssessmentMethodId IS NULL
)

SELECT DISTINCT *
FROM missing_assessmentMethod;