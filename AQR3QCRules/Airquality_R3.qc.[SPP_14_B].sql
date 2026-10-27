USE [Airquality_R3];
GO

/****** Object:  View [qc].[SPP_14_B] ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Creation date: August 2025
-- QC rule code: SPP_14_B
-- QC rule name: SPP_14_B Cross-check - [ProcessDocumentId]
-- QC rule description: The ProcessDocumentId must refer to a document classified as SPP in DOC_02 and as ProcessDocument in DOC_03.

CREATE OR ALTER VIEW [qc].[SPP_14_B]
AS
WITH sp AS
(
    SELECT
        spp.CountryCode,
        spp.ProcessId,
        spp.AssessmentMethodId,
        spp.ProcessActivityBegin,
        spp.ProcessActivityEnd,
        spp.PollutantId,
        spp.ProcessDocumentId,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), spp.CountryCode))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode_norm,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), spp.ProcessDocumentId))),
            N''
        ) COLLATE Latin1_General_CI_AS AS ProcessDocumentId_norm
    FROM [reporting].[SamplingProcess] AS spp
)
SELECT
    s.CountryCode,
    s.ProcessId,
    s.AssessmentMethodId,
    s.ProcessActivityBegin,
    s.ProcessActivityEnd,
    s.PollutantId,
    s.ProcessDocumentId
FROM sp AS s
WHERE
    /* Only populated values are validated by this rule. */
    s.ProcessDocumentId_norm IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM [reporting].[Documentation] AS doc
        WHERE
            NULLIF
            (
                LTRIM(RTRIM(CONVERT(NVARCHAR(100), doc.CountryCode))),
                N''
            ) COLLATE Latin1_General_CI_AS = s.CountryCode_norm

            AND NULLIF
            (
                LTRIM(RTRIM(CONVERT(NVARCHAR(200), doc.DocumentId))),
                N''
            ) COLLATE Latin1_General_CI_AS = s.ProcessDocumentId_norm

            AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DataTable)))
                COLLATE Latin1_General_CI_AS
                = N'aq/datatable/SPP'

            AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DocumentType)))
                COLLATE Latin1_General_CI_AS
                = N'aq/documenttype/ProcessDocument'
    );
GO