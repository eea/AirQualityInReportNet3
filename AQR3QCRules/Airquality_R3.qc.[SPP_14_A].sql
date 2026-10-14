USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_14_A]    Script Date: 13/10/2026 12:32:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[SPP_14_A] AS

-- Creation date: August 2025
-- QC rule code: SPP_14_A
-- QC rule name: SPP_14_A Cross-check - [ProcessDocumentId]
-- QC rule description: The ProcessDocumentId must exist as a DocumentId in the Documentation table, either within the current R3 submission or in the reference dataset.

WITH sp AS (
SELECT
[CountryCode],
[AssessmentMethodId],
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [ProcessDocumentId]))), '') AS [ProcessDocumentId]
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
s.[ProcessDocumentId]
FROM sp s
WHERE s.[ProcessDocumentId] IS NULL
OR (
NOT EXISTS (SELECT 1 FROM doc_r r WHERE r.[DocumentId] = s.[ProcessDocumentId])
AND NOT EXISTS (SELECT 1 FROM doc_ref f WHERE f.[DocumentId] = s.[ProcessDocumentId])
);

GO


