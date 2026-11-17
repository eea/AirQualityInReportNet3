USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_10_A]    Script Date: 16/11/2026 12:38:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [qc].[SPP_10_A]
AS
/* ============================================================
   QC rule code: SPP_10_A
   QC rule name: SPP_10_A Vocabulary -[AnalyticalTechnique]
   QC rule description: AnalyticalTechnique shall be reported using a valid value from the analyticaltechnique vocabulary.

   ============================================================ */
WITH sp AS
(
    SELECT
        spp.CountryCode,
        spp.ProcessId,
        spp.AssessmentMethodId,
        spp.ProcessActivityBegin,
        spp.ProcessActivityEnd,
        spp.PollutantId,
        spp.MeasurementType,
        spp.AnalyticalTechnique,
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), spp.MeasurementType))),
            N''
        ) COLLATE Latin1_General_CI_AS AS MeasurementType_norm,
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), spp.AnalyticalTechnique))),
            N''
        ) COLLATE Latin1_General_CI_AS AS AnalyticalTechnique_norm
    FROM [reporting].[SamplingProcess] AS spp
)
SELECT
    s.CountryCode,
    s.ProcessId,
    s.AssessmentMethodId,
    s.ProcessActivityBegin,
    s.ProcessActivityEnd,
    s.PollutantId,
    s.AnalyticalTechnique,
    CASE
        WHEN s.MeasurementType_norm IN (N'Passive', N'Active')
             AND s.AnalyticalTechnique IS NULL
            THEN 'ANALYTICAL_TECHNIQUE_NULL'

        WHEN s.MeasurementType_norm IN (N'Passive', N'Active')
             AND s.AnalyticalTechnique_norm IS NULL
            THEN 'ANALYTICAL_TECHNIQUE_EMPTY'

        WHEN s.AnalyticalTechnique_norm IS NOT NULL
             AND NOT EXISTS
             (
                 SELECT 1
                 FROM [reference].[Vocabulary] AS v
                 WHERE v.vocabulary = 'analyticaltechnique'
                   AND v.Notation COLLATE Latin1_General_CI_AS
                       = s.AnalyticalTechnique_norm
             )
            THEN 'ANALYTICAL_TECHNIQUE_NOT_IN_VOCABULARY'
    END AS QC_FailureReason
FROM sp AS s
WHERE
    (
        s.MeasurementType_norm IN (N'Passive', N'Active')
        AND s.AnalyticalTechnique_norm IS NULL
    )
    OR
    (
        s.AnalyticalTechnique_norm IS NOT NULL
        AND NOT EXISTS
        (
            SELECT 1
            FROM [reference].[Vocabulary] AS v
            WHERE v.vocabulary = 'analyticaltechnique'
              AND v.Notation COLLATE Latin1_General_CI_AS
                  = s.AnalyticalTechnique_norm
        )
    );
GO