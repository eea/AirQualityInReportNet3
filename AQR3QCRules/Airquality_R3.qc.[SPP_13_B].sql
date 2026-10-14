USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_13_B]    Script Date: 14/10/2026 10:56:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [qc].[SPP_13_B]
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
        FROM [reporting].[Documentation] AS doc
        WHERE
            NULLIF(
                LTRIM(RTRIM(CONVERT(NVARCHAR(100), doc.CountryCode))),
                N''
            ) COLLATE Latin1_General_CI_AS = s.CountryCode_norm
            AND NULLIF(
                LTRIM(RTRIM(CONVERT(NVARCHAR(200), doc.DocumentId))),
                N''
            ) COLLATE Latin1_General_CI_AS = s.EquivalenceDemonstrationDocumentId_norm
            AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DataTable)))
                COLLATE Latin1_General_CI_AS = N'aq/datatable/SamplingProcess'
            AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DocumentType)))
                COLLATE Latin1_General_CI_AS =
                N'aq/documenttype/EquivalenceDemonstrationDocumentId'
    );
GO