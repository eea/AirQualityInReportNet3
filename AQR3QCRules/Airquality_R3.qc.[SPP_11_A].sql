USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_11_A]    Script Date: 08/10/2026 13:45:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter   VIEW [qc].[SPP_11_A]
AS
/* ============================================================
   QC rule code: SPP_11_A
   QC rule name: SPP_11_A Vocabulary - [EquivalenceDemonstrated]
   QC rule description: EquivalenceDemonstrated shall be reported using a valid value from the equivalencedemonstrated vocabulary.
  
   ============================================================ */
SELECT
    spp.CountryCode,
    spp.ProcessId,
    spp.AssessmentMethodId,
    spp.ProcessActivityBegin,
    spp.ProcessActivityEnd,
    spp.PollutantId,
    spp.EquivalenceDemonstrated,
    CASE
        WHEN spp.EquivalenceDemonstrated IS NULL
            THEN 'EQUIVALENCE_DEMONSTRATED_NULL'

        WHEN LTRIM(RTRIM(spp.EquivalenceDemonstrated)) = ''
            THEN 'EQUIVALENCE_DEMONSTRATED_EMPTY'

        WHEN NOT EXISTS
        (
            SELECT 1
            FROM [reference].[Vocabulary] AS v
            WHERE v.vocabulary = 'equivalencedemonstrated'
              AND v.Notation COLLATE Latin1_General_CI_AS
                  = LTRIM(RTRIM(spp.EquivalenceDemonstrated))
                    COLLATE Latin1_General_CI_AS
        )
            THEN 'EQUIVALENCE_DEMONSTRATED_NOT_IN_VOCABULARY'
    END AS QC_FailureReason
FROM [reporting].[SamplingProcess] AS spp
WHERE
    spp.EquivalenceDemonstrated IS NULL
    OR LTRIM(RTRIM(spp.EquivalenceDemonstrated)) = ''
    OR NOT EXISTS
    (
        SELECT 1
        FROM [reference].[Vocabulary] AS v
        WHERE v.vocabulary = 'equivalencedemonstrated'
          AND v.Notation COLLATE Latin1_General_CI_AS
              = LTRIM(RTRIM(spp.EquivalenceDemonstrated))
                COLLATE Latin1_General_CI_AS
    );
GO


