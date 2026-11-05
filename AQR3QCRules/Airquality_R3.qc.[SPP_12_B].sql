USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPP_12_B]
AS

-- Creation date: October 2026
-- QC rule code: SPP_12_B
-- QC rule name: SPP_12_B Cross-check - [DataQualityDocumentId]
-- QC rule description: The DataQualityDocumentId must refer to a document classified as SamplingProcess in DOC_02 and as DataQualityDocumentId in DOC_03.

WITH sp AS
(
    SELECT
        spp.[CountryCode],
        spp.[ProcessId],
        spp.[AssessmentMethodId],
        spp.[ProcessActivityBegin],
        spp.[ProcessActivityEnd],
        spp.[PollutantId],
        spp.[DataQualityDocumentId] AS DataQualityDocumentIdRaw,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(100), spp.[CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode_norm,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(nvarchar(200), spp.[DataQualityDocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DataQualityDocumentId
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

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM all_documents AS d
                WHERE d.DocumentId = s.DataQualityDocumentId
            )
            THEN 1 ELSE 0
        END AS DocumentExists,

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM all_documents AS d
                WHERE d.DocumentId = s.DataQualityDocumentId
                  AND d.CountryCode = s.CountryCode_norm
            )
            THEN 1 ELSE 0
        END AS DocumentExistsForCountry,

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM all_documents AS d
                WHERE d.DocumentId = s.DataQualityDocumentId
                  AND d.CountryCode = s.CountryCode_norm
                  AND d.DataTable = N'aq/datatable/SamplingProcess'
            )
            THEN 1 ELSE 0
        END AS HasExpectedDataTable,

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM all_documents AS d
                WHERE d.DocumentId = s.DataQualityDocumentId
                  AND d.CountryCode = s.CountryCode_norm
                  AND d.DocumentType = N'aq/documenttype/DataQualityDocumentId'
            )
            THEN 1 ELSE 0
        END AS HasExpectedDocumentType,

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM all_documents AS d
                WHERE d.DocumentId = s.DataQualityDocumentId
                  AND d.CountryCode = s.CountryCode_norm
                  AND d.DataTable = N'aq/datatable/SamplingProcess'
                  AND d.DocumentType = N'aq/documenttype/DataQualityDocumentId'
            )
            THEN 1 ELSE 0
        END AS HasValidDocument
    FROM sp AS s
)

SELECT
    CountryCode,
    ProcessId,
    AssessmentMethodId,
    ProcessActivityBegin,
    ProcessActivityEnd,
    PollutantId,
    DataQualityDocumentIdRaw AS DataQualityDocumentId,
    CASE
        WHEN DataQualityDocumentId IS NULL
            THEN 'DATA_QUALITY_DOCUMENTID_MISSING_OR_EMPTY'

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
WHERE DataQualityDocumentId IS NULL
   OR HasValidDocument = 0
GO