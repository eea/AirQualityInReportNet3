USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_13_B]    Script Date: 29/09/2026 13:19:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_13_B]
AS
/* ============================================================
   QC rule code: SPP_13_B
   QC rule name: EquivalenceDemonstrationDocumentId document
                 type and table origin validation

   EquivalenceDemonstrationDocumentId must match a record in
   reporting.Documentation, for the same CountryCode, with:

   - DataTable    = aq/datatable/SamplingProcess
   - DocumentType = aq/documenttype/EquivalenceDemonstrationDocumentId

   Missing or empty EquivalenceDemonstrationDocumentId values are
   expected to be validated by the corresponding mandatory-value
   rule.
   ============================================================ */
SELECT
    spp.CountryCode,
    spp.ProcessId,
    spp.AssessmentMethodId,
    spp.ProcessActivityBegin,
    spp.ProcessActivityEnd,
    spp.PollutantId,
    spp.EquivalenceDemonstrationDocumentId,
    'EquivalenceDemonstrationDocumentId does not match a reporting.Documentation record with the required DataTable and DocumentType for the same CountryCode.'
        AS QCMessage
FROM [reporting].[SamplingProcess] AS spp
WHERE
    /* This rule only checks populated document identifiers. */
    NULLIF(LTRIM(RTRIM(spp.EquivalenceDemonstrationDocumentId)), '') IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM [reporting].[Documentation] AS doc
        WHERE doc.CountryCode = spp.CountryCode
          AND doc.DocumentId = spp.EquivalenceDemonstrationDocumentId
          AND doc.DataTable = 'aq/datatable/SamplingProcess'
          AND doc.DocumentType = 'aq/documenttype/EquivalenceDemonstrationDocumentId'
    );
GO


