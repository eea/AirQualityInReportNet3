USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPP_14_B]
AS

-- Creation date: August 2025
-- QC rule code: SPP_14_B
-- QC rule name: SPP_14_B Cross-check - [ProcessDocumentId]
-- QC rule description: The ProcessDocumentId must refer to a document classified as SPP in DOC_02 and as ProcessDocument in DOC_03.

WITH sp AS
(
    SELECT
        spp.[CountryCode],
        spp.[ProcessId],
        spp.[AssessmentMethodId],
        spp.[ProcessActivityBegin],
        spp.[ProcessActivityEnd],
        spp.[PollutantId],
        spp.[ProcessDocumentId] AS ProcessDocumentIdRaw,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(100), spp.[CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode_norm,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(200), spp.[ProcessDocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS ProcessDocumentId
    FROM [reporting].[SamplingProcess] AS spp
),
all_documents AS
(
    SELECT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(100), d.[CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(200), d.[DocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentId,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(500), d.[DataTable]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DataTable,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(500), d.[DocumentType]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentType
    FROM [reporting].[Documentation] AS d

    UNION ALL

    SELECT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(100), d.[CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(200), d.[DocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(500), d.[DataTable]))),
            N''
        ) COLLATE Latin1_General_CI_AS,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(500), d.[DocumentType]))),
            N''
        ) COLLATE Latin1_General_CI_AS
    FROM [reference].[Documentation] AS d
),
document_validation AS
(
    SELECT
        s.*,

        CASE WHEN EXISTS
        (
            SELECT 1
            FROM all_documents AS d
            WHERE d.DocumentId = s.ProcessDocumentId
        )
        THEN 1 ELSE 0 END AS DocumentExists,

        CASE WHEN EXISTS
        (
            SELECT 1
            FROM all_documents AS d
            WHERE d.DocumentId = s.ProcessDocumentId
              AND d.CountryCode = s.CountryCode_norm
        )
        THEN 1 ELSE 0 END AS DocumentExistsForCountry,

        CASE WHEN EXISTS
        (
            SELECT 1
            FROM all_documents AS d
            WHERE d.DocumentId = s.ProcessDocumentId
              AND d.CountryCode = s.CountryCode_norm
              AND d.DataTable = N'aq/datatable/SPP'
        )
        THEN 1 ELSE 0 END AS HasExpectedDataTable,

        CASE WHEN EXISTS
        (
            SELECT 1
            FROM all_documents AS d
            WHERE d.DocumentId = s.ProcessDocumentId
              AND d.CountryCode = s.CountryCode_norm
              AND d.DocumentType = N'aq/documenttype/ProcessDocument'
        )
        THEN 1 ELSE 0 END AS HasExpectedDocumentType,

        CASE WHEN EXISTS
        (
            SELECT 1
            FROM all_documents AS d
            WHERE d.DocumentId = s.ProcessDocumentId
              AND d.CountryCode = s.CountryCode_norm
              AND d.DataTable = N'aq/datatable/SPP'
              AND d.DocumentType = N'aq/documenttype/ProcessDocument'
        )
        THEN 1 ELSE 0 END AS HasValidDocument
    FROM sp AS s
)
SELECT
    CountryCode,
    ProcessId,
    AssessmentMethodId,
    ProcessActivityBegin,
    ProcessActivityEnd,
    PollutantId,
    ProcessDocumentIdRaw AS ProcessDocumentId,
    CASE
        WHEN DocumentExists = 0
            THEN 'DOCUMENTID_NOT_FOUND'

        WHEN DocumentExistsForCountry = 0
            THEN 'DOCUMENTID_COUNTRYCODE_MISMATCH'

        WHEN HasExpectedDataTable = 0
         AND HasExpectedDocumentType = 0
            THEN 'DOCUMENTID_WRONG_DATATABLE_AND_DOCUMENTTYPE'

        WHEN HasExpectedDataTable = 0
            THEN 'DOCUMENTID_WRONG_DATATABLE'

        WHEN HasExpectedDocumentType = 0
            THEN 'DOCUMENTID_WRONG_DOCUMENTTYPE'

        ELSE 'DOCUMENTID_NOT_FOUND_WITH_EXPECTED_CLASSIFICATION'
    END AS QC_FailureReason
FROM document_validation
WHERE ProcessDocumentId IS NOT NULL
  AND HasValidDocument = 0
GO