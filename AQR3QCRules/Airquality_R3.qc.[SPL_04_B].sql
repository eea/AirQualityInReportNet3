USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_04_B]  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_04_B_TEST]
AS

WITH latest_location AS
(
    SELECT
        CountryCode,
        AssessmentMethodId,
        LocationBegin,
        LocationEnd,

        ROW_NUMBER() OVER
        (
            PARTITION BY CountryCode, AssessmentMethodId
            ORDER BY TRY_CONVERT(datetimeoffset(0), LocationBegin,126) DESC
        ) AS rn

    FROM reporting.SamplingPointLocation
),

latest_process AS
(
    SELECT
        CountryCode,
        AssessmentMethodId,
        ProcessActivityBegin,
        ProcessActivityEnd,

        ROW_NUMBER() OVER
        (
            PARTITION BY CountryCode, AssessmentMethodId
            ORDER BY TRY_CONVERT(datetimeoffset(0), ProcessActivityBegin,126) DESC
        ) AS rn

    FROM reporting.SamplingProcess
)

SELECT

    l.CountryCode,
    l.AssessmentMethodId,

    l.LocationBegin,
    l.LocationEnd,

    p.ProcessActivityBegin,
    p.ProcessActivityEnd

FROM latest_location l

INNER JOIN latest_process p

ON l.CountryCode = p.CountryCode
AND l.AssessmentMethodId = p.AssessmentMethodId

WHERE

l.rn = 1
AND p.rn = 1

AND
(
ISNULL(
TRY_CONVERT(datetimeoffset(0),l.LocationEnd,126),
'19000101'
)
<>
ISNULL(
TRY_CONVERT(datetimeoffset(0),p.ProcessActivityEnd,126),
'19000101'
)
);