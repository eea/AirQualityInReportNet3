USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[SPP_04_B]    Script Date: 02/07/2026 13:54:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE or alter   VIEW [qc].[SPP_04_B] AS
WITH src AS (
SELECT
[CountryCode],
[AssessmentMethodId],
[ProcessActivityBegin],
[ProcessActivityEnd],
--PArse ISO 8601; 
TRY_CONVERT(datetimeoffset(0),
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityBegin], 126))), ''),
126) AS Begin_dt,
TRY_CONVERT(datetimeoffset(0),
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd], 126))), ''),
126) AS End_dt
FROM [reporting].[SamplingProcess]
),
ordered AS (
SELECT
s.*,
MAX(End_dt) OVER (
PARTITION BY [CountryCode], [AssessmentMethodId]
ORDER BY Begin_dt
ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
) AS prev_max_end
FROM src s
),
-- TYpe 1 : Previous interval without End exists (later Begin present)
prev_open AS (
SELECT e.[CountryCode], e.[AssessmentMethodId],
e.[ProcessActivityBegin], e.[ProcessActivityEnd],
'Previous interval without End exists (later Begin present)' AS violation,
CAST(NULL AS datetimeoffset(0)) AS [LatestPreviousEnd]
FROM ordered e
WHERE e.End_dt IS NULL
AND e.Begin_dt IS NOT NULL
AND EXISTS (
SELECT 1
FROM ordered n
WHERE n.[CountryCode] = e.[CountryCode]
AND n.[AssessmentMethodId] = e.[AssessmentMethodId]
AND n.Begin_dt IS NOT NULL
AND n.Begin_dt > e.Begin_dt
)
),
-- Type 2: Begin earlier than latest previous End
order_err AS (
SELECT n.[CountryCode], n.[AssessmentMethodId],
n.[ProcessActivityBegin], n.[ProcessActivityEnd],
'Begin earlier than latest previous End' AS violation,
n.prev_max_end AS [LatestPreviousEnd]
FROM ordered n
WHERE n.Begin_dt IS NOT NULL
AND n.prev_max_end IS NOT NULL
AND n.Begin_dt < n.prev_max_end
)
SELECT * FROM prev_open
UNION ALL
SELECT * FROM order_err;

GO


