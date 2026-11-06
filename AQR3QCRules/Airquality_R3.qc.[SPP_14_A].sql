USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_14_A]    Script Date: 06/11/2026 14:13:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Creation date: August 2025
-- QC rule code: SPP_14_A
-- QC rule name: SPP_14_A Cross-check - [ProcessDocumentId]
-- QC rule description: The ProcessDocumentId must exist as a DocumentId in the Documentation table, either within the current R3 submission or in the reference dataset.

CREATE OR ALTER VIEW [qc].[SPP_14_A]
AS
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
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), spp.[CountryCode]))),
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
                        spp.[ProcessDocumentId]
                    )
                )
            ),
            N''
        ) COLLATE Latin1_General_CI_AS AS ProcessDocumentId
    FROM [reporting].[SamplingProcess] AS spp
),
doc_r AS
(
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), d.[CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), d.[DocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentId
    FROM [reporting].[Documentation] AS d
),
doc_ref AS
(
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), d.[CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), d.[DocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS DocumentId
    FROM [reference].[Documentation] AS d
)
SELECT
    s.[CountryCode],
    s.[ProcessId],
    s.[AssessmentMethodId],
    s.[ProcessActivityBegin],
    s.[ProcessActivityEnd],
    s.[PollutantId],
    s.ProcessDocumentIdRaw AS ProcessDocumentId,
    CASE
        WHEN s.ProcessDocumentId IS NULL
            THEN 'PROCESS_DOCUMENTID_MISSING_OR_EMPTY'
        ELSE 'PROCESS_DOCUMENTID_NOT_FOUND_FOR_COUNTRYCODE'
    END AS QC_FailureReason
FROM sp AS s
WHERE
    s.ProcessDocumentId IS NULL
    OR
    (
        NOT EXISTS
        (
            SELECT 1
            FROM doc_r AS r
            WHERE r.[CountryCode] = s.CountryCode_norm
              AND r.[DocumentId] = s.ProcessDocumentId
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM doc_ref AS f
            WHERE f.[CountryCode] = s.CountryCode_norm
              AND f.[DocumentId] = s.ProcessDocumentId
        )
    );
GO