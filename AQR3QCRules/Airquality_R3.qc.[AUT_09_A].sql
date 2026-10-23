USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[AUT_09_A]
AS

-- Creation date: 23 October 2026
-- QC rule code: AUT_09_A
-- QC rule name: AUT_09_A Content - [PersonName]
-- QC rule description: PersonName must be provided and not null. The option "Not Reported" is accepted.

SELECT
    [CountryCode],
    [AuthorityInstanceId],
    [AuthorityRole],
    [Email],
    [PersonName]
FROM [reporting].[Authority]
WHERE NULLIF(LTRIM(RTRIM([PersonName])), '') IS NULL;
GO