USE [Airquality_R3];
GO

/****** Object: View [qc].[ARZ_19_B] Script Date: 21/09/2026 12:44:36 ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

/* ============================================================
   QC ARZ_19_B

   ClassificationDocumentId must refer to a document in
   reporting.Documentation for the same CountryCode, with:

   - DataTable    = aq/datatable/AssessmentRegimeZone
   - DocumentType = aq/documenttype/ClassificationDocument

   Missing, NULL, or empty ClassificationDocumentId values are
   validated by ARZ_19_A.
   ============================================================ */
CREATE OR ALTER VIEW [qc].[ARZ_19_B]
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

    /* Error message returned for non-compliant records. */
    'ClassificationDocumentId does not match a reporting.Documentation record with the required DataTable and DocumentType for the same CountryCode.'
        AS QCMessage
FROM [reporting].[AssessmentRegimeZone] AS arz
WHERE
    /* ARZ_19_A validates missing, NULL, and empty values. */
    NULLIF(LTRIM(RTRIM(arz.ClassificationDocumentId)), '') IS NOT NULL

    /* Return the record when no matching document has the required metadata. */
    AND NOT EXISTS
    (
        SELECT 1
        FROM [reporting].[Documentation] AS doc
        WHERE
            /* The document must belong to the same reporting country. */
            doc.CountryCode = arz.CountryCode

            /* The document identifier must match ClassificationDocumentId. */
            AND doc.DocumentId = arz.ClassificationDocumentId

            /* The document must originate from the AssessmentRegimeZone table. */
            AND doc.DataTable = 'aq/datatable/AssessmentRegimeZone'

            /* The document must be a ClassificationDocument. */
            AND doc.DocumentType = 'aq/documenttype/ClassificationDocument'
    );
GO