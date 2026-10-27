USE [Airquality_R3];
GO

/****** Object:  View [qctesting].[SPP_13_B_TEST] ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Creation date: August 2025
-- QC rule code: SPP_13_B
-- QC rule name: SPP_13_B Cross-check - [EquivalenceDemonstrationDocumentId]
-- QC rule description: The EquivalenceDemonstrationDocumentId must refer to a document classified as SPP in DOC_02 and as EquivalenceDemonstrationDocument in DOC_03.

CREATE OR ALTER VIEW [qctesting].[SPP_13_B_TEST]
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
        spp.EquivalenceDemonstrationDocumentId,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), spp.CountryCode))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode_norm,

        NULLIF
        (
            LTRIM
            (
                RTRIM
                (
                    CONVERT
                    (
                        NVARCHAR(200),
                        spp.EquivalenceDemonstrationDocumentId
                    )
                )
            ),
            N''
        ) COLLATE Latin1_General_CI_AS AS EquivalenceDemonstrationDocumentId_norm
    FROM [qctesting].[SamplingProcess] AS spp
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
    /* This rule only checks populated document identifiers. */
    s.EquivalenceDemonstrationDocumentId_norm IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM [qctesting].[Documentation] AS doc
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
            ) COLLATE Latin1_General_CI_AS
                = s.EquivalenceDemonstrationDocumentId_norm

            AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DataTable)))
                COLLATE Latin1_General_CI_AS
                = N'aq/datatable/SPP'

            AND LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DocumentType)))
                COLLATE Latin1_General_CI_AS
                = N'aq/documenttype/EquivalenceDemonstrationDocument'
    );
GO