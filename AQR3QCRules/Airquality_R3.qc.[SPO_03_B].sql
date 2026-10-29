USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_03_B]
AS

-- Creation date: October 2026
-- QC rule code: SPO_03_B
-- QC rule name: SPO_03_B Format - [SamplingPointReferenceId]
-- QC rule description: SamplingPointReferenceId shall follow the official sampling point reference identifier format and be consistent with the reported StationEoICode and PollutantId.

WITH sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId,
        NULLIF(LTRIM(RTRIM([SamplingPointReferenceId])), '') AS SamplingPointReferenceId,
        NULLIF(LTRIM(RTRIM([StationEoICode])), '') AS StationEoICode,
        [PollutantId]
    FROM [reporting].[SamplingPoint]
),
expected_identifier AS
(
    SELECT
        sp.CountryCode,
        sp.AssessmentMethodId,
        sp.SamplingPointReferenceId,
        sp.StationEoICode,
        sp.PollutantId,
        CONCAT(
            'SPOref_',
            sp.StationEoICode,
            '_',
            CONVERT(varchar(11), sp.PollutantId),
            '_'
        ) AS ExpectedPrefix
    FROM sampling_points AS sp
),
parsed_identifier AS
(
    SELECT
        e.CountryCode,
        e.AssessmentMethodId,
        e.SamplingPointReferenceId,
        e.StationEoICode,
        e.PollutantId,
        e.ExpectedPrefix,
        CASE
            WHEN e.SamplingPointReferenceId LIKE e.ExpectedPrefix + '%'
            THEN SUBSTRING(
                e.SamplingPointReferenceId,
                LEN(e.ExpectedPrefix) + 1,
                LEN(e.SamplingPointReferenceId)
            )
        END AS OrderingIndex
    FROM expected_identifier AS e
)
SELECT
    p.CountryCode,
    p.AssessmentMethodId,
    p.SamplingPointReferenceId,
    p.StationEoICode,
    p.PollutantId
FROM parsed_identifier AS p
WHERE p.SamplingPointReferenceId IS NULL
   OR p.StationEoICode IS NULL
   OR p.PollutantId IS NULL
   OR p.SamplingPointReferenceId NOT LIKE p.ExpectedPrefix + '%'
   OR p.OrderingIndex IS NULL
   OR p.OrderingIndex = ''
   OR p.OrderingIndex LIKE '%[^0-9]%'
   OR TRY_CONVERT(int, p.OrderingIndex) IS NULL
   OR TRY_CONVERT(int, p.OrderingIndex) <= 0
GO