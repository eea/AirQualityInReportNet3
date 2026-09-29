USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_10_A]    Script Date: 29/09/2026 14:12:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_10_A]
AS
/* ============================================================
   QC rule code: SPP_10_A
   QC rule name: SamplingProcess AnalyticalTechnique validity
   ============================================================ */
SELECT
    spp.CountryCode,
    spp.ProcessId,
    spp.AssessmentMethodId,
    spp.ProcessActivityBegin,
    spp.ProcessActivityEnd,
    spp.PollutantId,
    spp.AnalyticalTechnique,
    CASE
        WHEN spp.AnalyticalTechnique IS NULL
            THEN 'ANALYTICAL_TECHNIQUE_NULL'

        WHEN LTRIM(RTRIM(spp.AnalyticalTechnique)) = ''
            THEN 'ANALYTICAL_TECHNIQUE_EMPTY'

        WHEN NOT EXISTS
        (
            SELECT 1
            FROM [reference].[Vocabulary] AS v
            WHERE v.vocabulary = 'analyticaltechnique'
              AND v.Notation COLLATE Latin1_General_CI_AS
                  = LTRIM(RTRIM(spp.AnalyticalTechnique))
                    COLLATE Latin1_General_CI_AS
        )
            THEN 'ANALYTICAL_TECHNIQUE_NOT_IN_VOCABULARY'
    END AS QC_FailureReason
FROM [reporting].[SamplingProcess] AS spp
WHERE
    spp.AnalyticalTechnique IS NULL
    OR LTRIM(RTRIM(spp.AnalyticalTechnique)) = ''
    OR NOT EXISTS
    (
        SELECT 1
        FROM [reference].[Vocabulary] AS v
        WHERE v.vocabulary = 'analyticaltechnique'
          AND v.Notation COLLATE Latin1_General_CI_AS
              = LTRIM(RTRIM(spp.AnalyticalTechnique))
                COLLATE Latin1_General_CI_AS
    );
GO


