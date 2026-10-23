USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUT_06_A]    Script Date: 23/10/2026 12:16:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[AUT_06_A]
AS

-- Creation date: 21 October 2026
-- QC rule code: AUT_06_A
-- QC rule name: AUT_06_A Content - [AuthorityName]
-- QC rule description: AuthorityName must be provided and not null.

SELECT
    [CountryCode],
    [AuthorityInstanceId],
    [AuthorityRole],
    [Email],
    [AuthorityName]
FROM [reporting].[Authority]
WHERE NULLIF(LTRIM(RTRIM([AuthorityName])), '') IS NULL;
GO


