USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_04_A]
AS

-- QC rule code: SPO_04_A
-- QC rule name: SPO_04_A Vocabulary - [PollutantId]
-- QC rule description: PollutantId from the SamplingPoint table must be reported using a valid value from the pollutant vocabulary.

WITH sampling_points AS
(
    SELECTUSE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_05_A]
AS

-- QC rule code: SPO_05_A
-- QC rule name: SPO_05_A Cross-check - [StationEoICode]
-- QC rule description: The StationEoICode reported in the SamplingPoint table shall exist in the MeasurementStation table.

WITH sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId,
        NULLIF(LTRIM(RTRIM([StationEoICode])), '') AS StationEoICode
    FROM [reporting].[SamplingPoint]
),
reported_stations AS
(
    SELECT DISTINCT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([StationEoICode])), '') AS StationEoICode
    FROM [reporting].[MeasurementStation]
),
reference_stations AS
(
    SELECT DISTINCT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([StationEoICode])), '') AS StationEoICode
    FROM [reference].[MeasurementStation]
),
reported_station_countries AS
(
    SELECT DISTINCT
        CountryCode
    FROM reported_stations
    WHERE CountryCode IS NOT NULL
)
SELECT
    sp.CountryCode,
    sp.AssessmentMethodId,
    sp.StationEoICode
FROM sampling_points AS sp
LEFT JOIN reported_station_countries AS rsc
    ON sp.CountryCode COLLATE DATABASE_DEFAULT =
       rsc.CountryCode COLLATE DATABASE_DEFAULT
LEFT JOIN reported_stations AS rs
    ON sp.CountryCode COLLATE DATABASE_DEFAULT =
       rs.CountryCode COLLATE DATABASE_DEFAULT
   AND sp.StationEoICode COLLATE DATABASE_DEFAULT =
       rs.StationEoICode COLLATE DATABASE_DEFAULT
LEFT JOIN reference_stations AS ref
    ON sp.CountryCode COLLATE DATABASE_DEFAULT =
       ref.CountryCode COLLATE DATABASE_DEFAULT
   AND sp.StationEoICode COLLATE DATABASE_DEFAULT =
       ref.StationEoICode COLLATE DATABASE_DEFAULT
WHERE sp.StationEoICode IS NULL
   OR
   (
       rsc.CountryCode IS NOT NULL
       AND rs.StationEoICode IS NULL
   )
   OR
   (
       rsc.CountryCode IS NULL
       AND ref.StationEoICode IS NULL
   )
GO
        [CountryCode],
        [AssessmentMethodId],
        [PollutantId]
    FROM [reporting].[SamplingPoint]
),
pollutant_vocabulary AS
(
    SELECT DISTINCT
        TRY_CONVERT(int, LTRIM(RTRIM([Notation]))) AS PollutantId
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] COLLATE DATABASE_DEFAULT =
          'pollutant' COLLATE DATABASE_DEFAULT
)
SELECT
    sp.CountryCode,
    sp.AssessmentMethodId,
    sp.PollutantId
FROM sampling_points AS sp
LEFT JOIN pollutant_vocabulary AS pv
    ON sp.PollutantId = pv.PollutantId
WHERE sp.PollutantId IS NULL
   OR pv.PollutantId IS NULL
GO