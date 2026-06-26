USE [Airquality_R3]
GO

/****** Object:  View [qc].[[SPP_13_A]]     ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[SPP_13_A] AS
WITH sp AS (
SELECT
[CountryCode],
[AssessmentMethodId],
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [EquivalenceDemonstrationDocumentId]))), '') AS [EquivalenceDemonstrationDocumentId]
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
s.[EquivalenceDemonstrationDocumentId]
FROM sp s
WHERE s.[EquivalenceDemonstrationDocumentId] IS NULL
OR (
NOT EXISTS (SELECT 1 FROM doc_r r WHERE r.[DocumentId] = s.[EquivalenceDemonstrationDocumentId])
AND NOT EXISTS (SELECT 1 FROM doc_ref f WHERE f.[DocumentId] = s.[EquivalenceDemonstrationDocumentId])
);
go
