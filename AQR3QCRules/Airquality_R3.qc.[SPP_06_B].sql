USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_06_B]    Script Date: 02/11/2026 12:35:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- QC rule code: SPP_06_B
-- QC rule name: SPP_06_B Cross-check [AssessmentMethodId], [PollutantId]
-- QC rule description: PollutantId reported in the SamplingProcess table shall be consistent with the PollutantId reported for the corresponding AssessmentMethodId in the SamplingPoint table.

CREATE OR ALTER     VIEW [qc].[SPP_06_B]
AS
WITH sp AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS [CountryCode],
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS [AssessmentMethodId],
        TRY_CONVERT
        (
            int,
            TRY_CONVERT
            (
                decimal(32,16),
                NULLIF
                (
                    LTRIM(RTRIM(CONVERT(nvarchar(200), [PollutantId]))),
                    ''
                )
            )
        ) AS [PollutantId]
    FROM [reporting].[SamplingProcess]
),
valid_sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS [CountryCode],
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS [AssessmentMethodId],
        TRY_CONVERT
        (
            int,
            TRY_CONVERT
            (
                decimal(32,16),
                NULLIF
                (
                    LTRIM(RTRIM(CONVERT(nvarchar(200), [PollutantId]))),
                    ''
                )
            )
        ) AS [PollutantId]
    FROM [reporting].[SamplingPoint]

    UNION

    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS [CountryCode],
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS [AssessmentMethodId],
        TRY_CONVERT
        (
            int,
            TRY_CONVERT
            (
                decimal(32,16),
                NULLIF
                (
                    LTRIM(RTRIM(CONVERT(nvarchar(200), [PollutantId]))),
                    ''
                )
            )
        ) AS [PollutantId]
    FROM [reference].[SamplingPoint]
)
SELECT
    s.[CountryCode],
    s.[AssessmentMethodId],
    s.[PollutantId]
FROM sp AS s
LEFT JOIN valid_sampling_points AS p
    ON  p.[CountryCode] = s.[CountryCode]
    AND p.[AssessmentMethodId] = s.[AssessmentMethodId]
    AND p.[PollutantId] = s.[PollutantId]
WHERE
    s.[CountryCode] IS NULL
    OR s.[AssessmentMethodId] IS NULL
    OR s.[PollutantId] IS NULL
    OR p.[CountryCode] IS NULL;
GO


