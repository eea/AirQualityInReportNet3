USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_06_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_06_A_TEST] 
AS

WITH CTE_samplingPointCategory AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([SamplingPointCategory])), '') AS [SamplingPointCategory]
    FROM reporting.SamplingPointLocation
),

missing_codes AS
(
    SELECT
        c.[SamplingPointCategory]

    FROM CTE_samplingPointCategory c

    LEFT JOIN reference.[Vocabulary] v
        ON c.[SamplingPointCategory] = v.[Notation] COLLATE Latin1_General_CI_AS
       AND v.[Vocabulary] = 'samplingpointcategory'

    WHERE
        c.[SamplingPointCategory] IS NOT NULL
        AND v.[Notation] IS NULL
)

SELECT DISTINCT *
FROM missing_codes;

GO