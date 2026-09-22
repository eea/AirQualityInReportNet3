USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_19_A]    Script Date: 21/09/2026 12:43:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* ============================================================
   QC ARZ_19_A
   ClassificationDocumentId must:
   - be populated;
   - exist in reporting.Documentation for the same CountryCode; or
   - exist as ClassificationDocumentId in reference.AssessmentRegimeZone
     for the same CountryCode.
   ============================================================ */
CREATE   VIEW [qc].[ARZ_19_A]
AS
SELECT
    arz.CountryCode,
    arz.AssessmentRegimeId,
    arz.ZoneId,
    arz.PollutantId,
    arz.ProtectionTarget,
    arz.ObjectiveType,
    arz.ReportingMetric,
    arz.ClassificationYear,
    arz.ClassificationDocumentId,
    CASE
        WHEN NULLIF(LTRIM(RTRIM(arz.ClassificationDocumentId)), '') IS NULL
            THEN 'ClassificationDocumentId is missing.'
        WHEN NOT EXISTS
        (
            SELECT 1
            FROM [reporting].[Documentation] AS doc
            WHERE doc.CountryCode = arz.CountryCode
              AND doc.DocumentId = arz.ClassificationDocumentId
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM [reference].[AssessmentRegimeZone] AS arz_ref
            WHERE arz_ref.CountryCode = arz.CountryCode
              AND arz_ref.ClassificationDocumentId = arz.ClassificationDocumentId
        )
            THEN 'ClassificationDocumentId does not exist in reporting.Documentation or reference.AssessmentRegimeZone for the same CountryCode.'
    END AS QCMessage
FROM [reporting].[AssessmentRegimeZone] AS arz
WHERE NULLIF(LTRIM(RTRIM(arz.ClassificationDocumentId)), '') IS NULL
   OR
   (
        NOT EXISTS
        (
            SELECT 1
            FROM [reporting].[Documentation] AS doc
            WHERE doc.CountryCode = arz.CountryCode
              AND doc.DocumentId = arz.ClassificationDocumentId
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM [reference].[AssessmentRegimeZone] AS arz_ref
            WHERE arz_ref.CountryCode = arz.CountryCode
              AND arz_ref.ClassificationDocumentId = arz.ClassificationDocumentId
        )
   );

GO


