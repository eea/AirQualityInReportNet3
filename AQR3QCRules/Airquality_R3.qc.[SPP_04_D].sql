USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_04_D]    Script Date: 29/09/2026 13:20:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_04_D]
AS
/* ============================================================
   QC rule code: SPP_04_D
   QC rule name: Overall SamplingProcess activity period matches
                 overall SamplingPointLocation period

   Aggregation level:
   - CountryCode
   - AssessmentMethodId

   Validation rules:
   1. Earliest ProcessActivityBegin = earliest LocationBegin.
   2. Latest closed ProcessActivityEnd = latest closed LocationEnd.
   3. If any SamplingProcess is open-ended, at least one
      SamplingPointLocation must be open-ended.
   ============================================================ */

WITH ProcessPeriod AS
(
    SELECT
        spp.CountryCode,
        spp.AssessmentMethodId,
        MIN(spp.ProcessActivityBegin) AS EarliestProcessActivityBegin,
        MAX(spp.ProcessActivityEnd) AS LatestProcessActivityEnd,
        MAX(
            CASE
                WHEN spp.ProcessActivityEnd IS NULL THEN 1
                ELSE 0
            END
        ) AS HasOpenEndedProcess
    FROM [reporting].[SamplingProcess] AS spp
    GROUP BY
        spp.CountryCode,
        spp.AssessmentMethodId
),
LocationPeriod AS
(
    SELECT
        spl.CountryCode,
        spl.AssessmentMethodId,
        MIN(spl.LocationBegin) AS EarliestLocationBegin,
        MAX(spl.LocationEnd) AS LatestLocationEnd,
        MAX(
            CASE
                WHEN spl.LocationEnd IS NULL THEN 1
                ELSE 0
            END
        ) AS HasOpenEndedLocation
    FROM [reporting].[SamplingPointLocation] AS spl
    GROUP BY
        spl.CountryCode,
        spl.AssessmentMethodId
),
InvalidPeriodGroups AS
(
    SELECT
        pp.CountryCode,
        pp.AssessmentMethodId,
        CASE
            WHEN lp.CountryCode IS NULL
                THEN 'MISSING_SAMPLING_POINT_LOCATION'

            WHEN pp.EarliestProcessActivityBegin <> lp.EarliestLocationBegin
                THEN 'EARLIEST_ACTIVITY_BEGIN_DOES_NOT_MATCH_LOCATION_BEGIN'

            WHEN pp.HasOpenEndedProcess = 1
                 AND ISNULL(lp.HasOpenEndedLocation, 0) = 0
                THEN 'OPEN_ENDED_PROCESS_WITHOUT_OPEN_ENDED_LOCATION'

            WHEN pp.HasOpenEndedProcess = 0
                 AND pp.LatestProcessActivityEnd <> lp.LatestLocationEnd
                THEN 'LATEST_ACTIVITY_END_DOES_NOT_MATCH_LOCATION_END'
        END AS QC_FailureReason
    FROM ProcessPeriod AS pp
    LEFT JOIN LocationPeriod AS lp
        ON  lp.CountryCode = pp.CountryCode
        AND lp.AssessmentMethodId = pp.AssessmentMethodId
    WHERE
        lp.CountryCode IS NULL
        OR pp.EarliestProcessActivityBegin <> lp.EarliestLocationBegin
        OR
        (
            pp.HasOpenEndedProcess = 1
            AND ISNULL(lp.HasOpenEndedLocation, 0) = 0
        )
        OR
        (
            pp.HasOpenEndedProcess = 0
            AND pp.LatestProcessActivityEnd <> lp.LatestLocationEnd
        )
)
SELECT
    spp.CountryCode,
    spp.ProcessId,
    spp.AssessmentMethodId,
    spp.ProcessActivityBegin,
    spp.ProcessActivityEnd,
    spp.PollutantId,
    ipg.QC_FailureReason
FROM [reporting].[SamplingProcess] AS spp
INNER JOIN InvalidPeriodGroups AS ipg
    ON  ipg.CountryCode = spp.CountryCode
    AND ipg.AssessmentMethodId = spp.AssessmentMethodId;
GO


