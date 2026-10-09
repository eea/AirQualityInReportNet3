USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_12_B]    Script Date: 09/10/2026 12:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_12_B]
AS

-- Creation date: October 2026
--QC code: SPP_12_B
--QC name: SPP_12_B Cross-check - [DataQualityDocumentId]
--QC rule description: The DataQualityDocumentId must refer to a document classified as SamplingProcess in DOC_02 and as DataQualityDocumentId in DOC_03.

WITH sp AS
(
    SELECT
        spp.CountryCode,
        spp.ProcessId,
        spp.AssessmentMethodId,
        spp.ProcessActivityBegin,
        spp.ProcessActivityEnd,
        spp.PollutantId,
        spp.DataQualityDocumentId AS DataQualityDocumentIdRaw,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), spp.DataQualityDocumentId))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DataQualityDocumentId
    FROM [reporting].[SamplingProcess] AS spp
),
valid_documents AS
(
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), d.DocumentId))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentId
    FROM [reporting].[Documentation] AS d
    WHERE LTRIM(RTRIM(CONVERT(NVARCHAR(500), d.DataTable)))
              COLLATE Latin1_General_CI_AS
              = N'aq/datatable/SamplingProcess'
      AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), d.DocumentType)))
              COLLATE Latin1_General_CI_AS
              = N'aq/documenttype/DataQualityDocumentId'

    UNION

    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), d.DocumentId))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentId
    FROM [reference].[Documentation] AS d
    WHERE LTRIM(RTRIM(CONVERT(NVARCHAR(500), d.DataTable)))
              COLLATE Latin1_General_CI_AS
              = N'aq/datatable/SamplingProcess'
      AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), d.DocumentType)))
              COLLATE Latin1_General_CI_AS
              = N'aq/documenttype/DataQualityDocumentId'
)
SELECT
    s.CountryCode,
    s.ProcessId,
    s.AssessmentMethodId,
    s.ProcessActivityBegin,
    s.ProcessActivityEnd,
    s.PollutantId,
    s.DataQualityDocumentIdRaw AS DataQualityDocumentId,
    CASE
        WHEN s.DataQualityDocumentId IS NULL
            THEN 'DATA_QUALITY_DOCUMENTID_MISSING_OR_EMPTY'

        ELSE 'DOCUMENTID_NOT_FOUND_WITH_EXPECTED_DATATABLE_AND_DOCUMENTTYPE'
    END AS QC_FailureReason
FROM sp AS s
WHERE s.DataQualityDocumentId IS NULL
   OR NOT EXISTS
   (
       SELECT 1
       FROM valid_documents AS d
       WHERE d.DocumentId = s.DataQualityDocumentId
   );
GO


