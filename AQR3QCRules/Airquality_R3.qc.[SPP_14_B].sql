USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_14_B]    Script Date: 14/10/2026 10:57:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE     VIEW [qc].[SPP_14_B]
AS
-- Creation date: August 2025
-- QC rule code: SPP_14_B
-- QC rule name: SPP_14_B Cross-check - [ProcessDocumentId]
-- QC rule description: The ProcessDocumentId must refer to a document classified as SamplingProcess in DOC_02 and as ProcessDocumentId in DOC_03.
SELECT
    spp.CountryCode,
    spp.ProcessId,
    spp.AssessmentMethodId,
    spp.ProcessActivityBegin,
    spp.ProcessActivityEnd,
    spp.PollutantId,
    spp.ProcessDocumentId
FROM [reporting].[SamplingProcess] AS spp
WHERE
    /* Only populated values are validated by this rule. */
    NULLIF(LTRIM(RTRIM(spp.ProcessDocumentId)), '') IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM [reporting].[Documentation] AS doc
        WHERE --doc.CountryCode = spp.CountryCode AND
           doc.DocumentId = spp.ProcessDocumentId
          AND doc.DataTable = 'aq/datatable/SamplingProcess'
          AND doc.DocumentType = 'aq/documenttype/ProcessDocumentId'
    );
GO


