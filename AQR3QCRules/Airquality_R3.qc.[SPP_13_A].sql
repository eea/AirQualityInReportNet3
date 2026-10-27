USE [Airquality_R3];
GO

/****** Object:  View [qc].[SPP_13_A] ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Creation date: August 2025
-- QC rule code: SPP_13_A
-- QC rule name: SPP_13_A Cross-check - [EquivalenceDemonstrationDocumentId]
-- QC rule description: The EquivalenceDemonstrationDocumentId must exist as a DocumentId in the Documentation table, either within the current R3 submission or in the reference dataset.

CREATE OR ALTER VIEW [qc].[SPP_13_A]
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
        spp.[EquivalenceDemonstrationDocumentId]
            AS EquivalenceDemonstrationDocumentIdRaw,

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
                        spp.[EquivalenceDemonstrationDocumentId]
                    )
                )
            ),
            N''
        ) COLLATE Latin1_General_CI_AS
            AS EquivalenceDemonstrationDocumentId
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
    s.EquivalenceDemonstrationDocumentIdRaw
        AS EquivalenceDemonstrationDocumentId,
    CASE
        WHEN s.EquivalenceDemonstrationDocumentId IS NULL
            THEN 'EQUIVALENCE_DEMONSTRATION_DOCUMENTID_MISSING_OR_EMPTY'
        ELSE 'EQUIVALENCE_DEMONSTRATION_DOCUMENTID_NOT_FOUND_FOR_COUNTRYCODE'
    END AS QC_FailureReason
FROM sp AS s
WHERE
    s.EquivalenceDemonstrationDocumentId IS NULL
    OR
    (
        NOT EXISTS
        (
            SELECT 1
            FROM doc_r AS r
            WHERE r.[CountryCode] = s.CountryCode_norm
              AND r.[DocumentId] = s.EquivalenceDemonstrationDocumentId
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM doc_ref AS f
            WHERE f.[CountryCode] = s.CountryCode_norm
              AND f.[DocumentId] = s.EquivalenceDemonstrationDocumentId
        )
    );
GO