USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUT_08_A]    Script Date: 23/10/2026 12:16:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[AUT_08_A]
AS

-- Creation date: 21 October 2026
-- QC rule code: AUT_08_A
-- QC rule name: AUT_08_A Content - [AuthorityAddress]
-- QC rule description: AuthorityAddress must be provided and not null.

SELECT
    [CountryCode],
    [AuthorityInstanceId],
    [AuthorityRole],
    [Email],
    [AuthorityAddress]
FROM [reporting].[Authority]
WHERE NULLIF(LTRIM(RTRIM([AuthorityAddress])), '') IS NULL;
GO


