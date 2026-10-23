USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUT_04_A]    Script Date: 23/10/2026 12:15:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[AUT_04_A]
AS

-- Creation date: 21 October 2026
-- QC rule code: AUT_04_A
-- QC rule name: AUT_04_A Format - [Email]
-- QC rule description: The Email field in the Authority table should contain a valid email address format. The QC should verify that each value includes all required elements of a standard email address, specifically: presence of a single @ symbol separating local and domain parts; a valid domain name with at least one period (e.g. domain.eu); and no spaces or disallowed characters.

WITH CTE_authority AS
(
    SELECT
        NULLIF([Email], '') AS Email
    FROM [reporting].[Authority]
),
CTE_email_parts AS
(
    SELECT
        a.Email,
        CHARINDEX('@', a.Email) AS AtPosition,
        LEN(a.Email) - LEN(REPLACE(a.Email, '@', '')) AS AtCount
    FROM CTE_authority AS a
    WHERE a.Email IS NOT NULL
),
CTE_email_structure AS
(
    SELECT
        e.Email,
        e.AtPosition,
        e.AtCount,
        CASE
            WHEN e.AtPosition > 1
                THEN LEFT(e.Email, e.AtPosition - 1)
            ELSE ''
        END AS LocalPart,
        CASE
            WHEN e.AtPosition > 0
                THEN SUBSTRING(e.Email, e.AtPosition + 1, LEN(e.Email))
            ELSE ''
        END AS DomainPart
    FROM CTE_email_parts AS e
),
CTE_invalid_emails AS
(
    SELECT
        e.Email
    FROM CTE_email_structure AS e
    WHERE
        -- The email address must contain exactly one @ symbol.
        e.AtCount <> 1

        -- Local and domain parts must contain a value.
        OR e.AtPosition <= 1
        OR e.AtPosition >= LEN(e.Email)

        -- Spaces are not allowed.
        OR CHARINDEX(' ', e.Email) > 0

        -- Allowed local-part characters: letters, digits, dot, underscore,
        -- percent sign, plus sign and hyphen.
        OR e.LocalPart COLLATE Latin1_General_100_BIN2
           LIKE '%[^A-Za-z0-9._%+-]%'

        -- The local part cannot start or end with a dot,
        -- and cannot contain consecutive dots.
        OR e.LocalPart LIKE '.%'
        OR e.LocalPart LIKE '%.'
        OR e.LocalPart LIKE '%..%'

        -- The domain part must contain at least one period.
        OR CHARINDEX('.', e.DomainPart) = 0

        -- Allowed domain characters: letters, digits, dot and hyphen.
        OR e.DomainPart COLLATE Latin1_General_100_BIN2
           LIKE '%[^A-Za-z0-9.-]%'

        -- The domain cannot start or end with a dot or hyphen,
        -- and cannot contain consecutive dots.
        OR e.DomainPart LIKE '.%'
        OR e.DomainPart LIKE '%.'
        OR e.DomainPart LIKE '-%'
        OR e.DomainPart LIKE '%-'
        OR e.DomainPart LIKE '%..%'
)
SELECT
    Email
FROM CTE_invalid_emails;
GO


