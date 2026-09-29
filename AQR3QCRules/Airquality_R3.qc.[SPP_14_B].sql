USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_14_B]    Script Date: 29/09/2026 13:19:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_14_B]
AS
/* ============================================================
   QC rule code: SPP_14_B
   QC rule name: ProcessDocumentId document type and table
                 origin validation

   ProcessDocumentId must match a record in reporting.Documentation
   for the same CountryCode, with:

   - DataTable    = aq/datatable/SamplingProcess
   - DocumentType = aq/documenttype/ProcessDocumentId

   Missing, empty, or non-existing ProcessDocumentId values are
   validated by SPP_14_A.
   ============================================================ */
SELECT
    spp.CountryCode,
    spp.ProcessId,
    spp.AssessmentMethodId,
    spp.ProcessActivityBegin,
    spp.ProcessActivityEnd,
    spp.PollutantId,
    spp.ProcessDocumentId,
    'ProcessDocumentId does not match a reporting.Documentation record with the required DataTable and DocumentType for the same CountryCode.'
        AS QCMessage
FROM [reporting].[SamplingProcess] AS spp
WHERE
    /* Only populated values are validated by this rule. */
    NULLIF(LTRIM(RTRIM(spp.ProcessDocumentId)), '') IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM [reporting].[Documentation] AS doc
        WHERE doc.CountryCode = spp.CountryCode
          AND doc.DocumentId = spp.ProcessDocumentId
          AND doc.DataTable = 'aq/datatable/SamplingProcess'
          AND doc.DocumentType = 'aq/documenttype/ProcessDocumentId'
    );
GO


