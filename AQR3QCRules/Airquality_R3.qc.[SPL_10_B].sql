USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPL_10_B_TEST]
AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Latitude],
        [Longitude],

        TRY_CONVERT(decimal(18,4), [Latitude]) AS Latitude_num,
        TRY_CONVERT(decimal(18,4), [Longitude]) AS Longitude_num

    FROM reporting.SamplingPointLocation
)

SELECT
    src.[CountryCode],
    src.[AssessmentMethodId],
    src.[Latitude],
    src.[Longitude]

FROM src

WHERE
    Latitude_num IS NOT NULL
    AND Longitude_num IS NOT NULL

    AND NOT EXISTS
    (
        SELECT 1
        FROM reporting.ZoneGeometry zg
        WHERE
            zg.CountryCode = src.CountryCode

            /*
                TODO:
                ZoneGeometryGeoJson is currently stored as GeoJSON text.

                Once a supported conversion from GeoJSON to a SQL Server
                geometry/geography object is available, verify that the point
                defined by Longitude_num and Latitude_num falls within at least
                one ZoneGeometryGeoJson for the same CountryCode.

            */
    );

GO