USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[STA_05_A]
AS
-- Creation date: 25 August 2025
-- QC rule code: STA.05.A
-- QC rule name: STA.05.A Vocabulary - [AirQualityNetworkOrganisationalLevel]
-- QC rule description: NetworkOrganisationalLevel shall be reported using a valid value from the organisationallevel vocabulary.

WITH CTE_station AS
(
    SELECT
        ms.CountryCode,
        ms.StationEoICode,
        ms.NetworkId,
        ms.NetworkOrganisationalLevel AS NetworkOrganisationalLevelRaw,

        NULLIF
        (
            LTRIM
            (
                RTRIM
                (
                    CONVERT
                    (
                        NVARCHAR(200),
                        ms.NetworkOrganisationalLevel
                    )
                )
            ),
            N''
        ) COLLATE Latin1_General_CI_AS AS NetworkOrganisationalLevel
    FROM [reporting].[MeasurementStation] AS ms
)
SELECT
    s.CountryCode,
    s.StationEoICode,
    s.NetworkId,
    s.NetworkOrganisationalLevelRaw AS NetworkOrganisationalLevel,
    CASE
        WHEN s.NetworkOrganisationalLevel IS NULL
            THEN 'NETWORK_ORGANISATIONAL_LEVEL_MISSING_OR_EMPTY'

        WHEN NOT EXISTS
        (
            SELECT 1
            FROM [reference].[Vocabulary] AS v
            WHERE v.vocabulary = 'organisationallevel'
              AND v.Notation COLLATE Latin1_General_CI_AS
                  = s.NetworkOrganisationalLevel
        )
            THEN 'NETWORK_ORGANISATIONAL_LEVEL_NOT_IN_VOCABULARY'
    END AS QC_FailureReason
FROM CTE_station AS s
WHERE
    s.NetworkOrganisationalLevel IS NULL
    OR NOT EXISTS
    (
        SELECT 1
        FROM [reference].[Vocabulary] AS v
        WHERE v.vocabulary = 'organisationallevel'
          AND v.Notation COLLATE Latin1_General_CI_AS
              = s.NetworkOrganisationalLevel
    );
GO