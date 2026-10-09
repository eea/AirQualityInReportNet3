USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_12_B]    Script Date: 29/09/2026 13:19:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Creation date: July 2026
--QC code: SPP_12_A2
--QC name: SPP_12_A2 Cross-check - [DataQualityDocumentId]
--QC rule description: The DataQualityDocumentId must exist as a DocumentId in the Documentation table, either within the current R3 submission or in the reference dataset.

CREATE VIEW [qc].[SPP_12_B] AS
WITH sp AS (
SELECT
[CountryCode],
[AssessmentMethodId],
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [DataQualityDocumentId]))), '') AS [DataQualityDocumentId]
FROM [reporting].[SamplingProcess]
),
doc_r AS (
SELECT DISTINCT
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [DocumentId]))), '') AS [DocumentId]
FROM [reporting].[Documentation]
),
doc_ref AS (
SELECT DISTINCT
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [DocumentId]))), '') AS [DocumentId]
FROM [reference].[Documentation]
)
SELECT
s.[CountryCode],
s.[AssessmentMethodId],
s.[DataQualityDocumentId]
FROM sp s
WHERE s.[DataQualityDocumentId] IS NULL
OR (
NOT EXISTS (SELECT 1 FROM doc_r r WHERE r.[DocumentId] = s.[DataQualityDocumentId])
AND NOT EXISTS (SELECT 1 FROM doc_ref f WHERE f.[DocumentId] = s.[DataQualityDocumentId])
);

GO


