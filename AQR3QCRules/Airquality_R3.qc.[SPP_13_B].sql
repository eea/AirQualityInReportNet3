USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_13_B]    Script Date: 06/11/2026 14:03:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [qc].[SPP_13_B]
AS
-- Creation date: August 2025
-- QC rule code: SPP_13_B
-- QC rule name: SPP_13_B Cross-check - [EquivalenceDemonstrationDocumentId]
-- QC rule description: The EquivalenceDemonstrationDocumentId must refer to a document classified as SamplingProcess in DOC_02 and as EquivalenceDemonstrationDocumentId in DOC_03.

WITH sp AS
(
    SELECT
        spp.CountryCode,
        spp.ProcessId,
        spp.AssessmentMethodId,
        spp.ProcessActivityBegin,
        spp.ProcessActivityEnd,
        spp.PollutantId,
        spp.EquivalenceDemonstrationDocumentId,
        NULLIF(
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), spp.CountryCode))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode_norm,
        NULLIF(
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), spp.EquivalenceDemonstrationDocumentId))),
            N''
        ) COLLATE Latin1_General_CI_AS AS EquivalenceDemonstrationDocumentId_norm
    FROM [reporting].[SamplingProcess] AS spp
),
valid_documentation AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), doc.CountryCode))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode_norm,
        NULLIF(
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), doc.DocumentId))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentId_norm
    FROM [reporting].[Documentation] AS doc
    WHERE
        LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DataTable)))
            COLLATE Latin1_General_CI_AS = N'aq/datatable/SPP'
        AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DocumentType)))
            COLLATE Latin1_General_CI_AS =
            N'aq/documenttype/EquivalenceDemonstrationDocument'

    UNION

    SELECT
        NULLIF(
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), doc.CountryCode))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode_norm,
        NULLIF(
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), doc.DocumentId))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentId_norm
    FROM [reference].[Documentation] AS doc
    WHERE
        LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DataTable)))
            COLLATE Latin1_General_CI_AS = N'aq/datatable/SPP'
        AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DocumentType)))
            COLLATE Latin1_General_CI_AS =
            N'aq/documenttype/EquivalenceDemonstrationDocument'
)
SELECT
    s.CountryCode,
    s.ProcessId,
    s.AssessmentMethodId,
    s.ProcessActivityBegin,
    s.ProcessActivityEnd,
    s.PollutantId,
    s.EquivalenceDemonstrationDocumentId
FROM sp AS s
WHERE
    s.EquivalenceDemonstrationDocumentId_norm IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM valid_documentation AS doc
        WHERE doc.CountryCode_norm = s.CountryCode_norm
          AND doc.DocumentId_norm = s.EquivalenceDemonstrationDocumentId_norm
    );
GO