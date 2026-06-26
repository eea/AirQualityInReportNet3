USE [Airquality_R3]
GO

/****** Object:  View [qc].[[[SPP_14_A]]]    Script Date: 30/10/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[SPP_14_A] AS
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