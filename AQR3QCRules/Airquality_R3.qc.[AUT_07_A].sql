USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUT_07_A]    Script Date: 23/10/2026 12:16:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[AUT_07_A]
AS

-- Creation date: 21 October 2026
-- QC rule code: AUT_07_A
-- QC rule name: AUT_07_A Format - [AuthorityURL]
-- QC rule description: The value provided in the AuthorityURL field of the Authority table must be a syntactically valid URL. The QC rule should test if the URL conforms to standard URL format (e.g., includes http:// or https://, valid domain, etc.).

WITH CTE_authority AS
(
    SELECT
        [CountryCode],
        [AuthorityInstanceId],
        [AuthorityRole],
        [Email],
        [AuthorityURL]
    FROM [reporting].[Authority]
    WHERE [AuthorityURL] IS NOT NULL
),
CTE_url_protocol AS
(
    SELECT
        a.[CountryCode],
        a.[AuthorityInstanceId],
        a.[AuthorityRole],
        a.[Email],
        a.[AuthorityURL],
        CASE
            WHEN LOWER(a.[AuthorityURL]) LIKE 'http://%' THEN 7
            WHEN LOWER(a.[AuthorityURL]) LIKE 'https://%' THEN 8
            ELSE 0
        END AS ProtocolLength
    FROM CTE_authority AS a
),
CTE_url_host_source AS
(
    SELECT
        u.[CountryCode],
        u.[AuthorityInstanceId],
        u.[AuthorityRole],
        u.[Email],
        u.[AuthorityURL],
        u.ProtocolLength,
        CASE
            WHEN u.ProtocolLength > 0
                THEN SUBSTRING(
                    u.[AuthorityURL],
                    u.ProtocolLength + 1,
                    LEN(u.[AuthorityURL])
                )
            ELSE ''
        END AS UrlAfterProtocol
    FROM CTE_url_protocol AS u
),
CTE_url_parts AS
(
    SELECT
        u.[CountryCode],
        u.[AuthorityInstanceId],
        u.[AuthorityRole],
        u.[Email],
        u.[AuthorityURL],
        u.ProtocolLength,
        LEFT(
            u.UrlAfterProtocol,
            PATINDEX('%[/?#]%', u.UrlAfterProtocol + '/') - 1
        ) AS DomainName
    FROM CTE_url_host_source AS u
),
CTE_invalid_urls AS
(
    SELECT
        u.[CountryCode],
        u.[AuthorityInstanceId],
        u.[AuthorityRole],
        u.[Email],
        u.[AuthorityURL]
    FROM CTE_url_parts AS u
    WHERE NULLIF(LTRIM(RTRIM(u.[AuthorityURL])), '') IS NULL
       OR u.ProtocolLength = 0
       OR NULLIF(u.DomainName, '') IS NULL
       OR CHARINDEX(' ', u.[AuthorityURL]) > 0
       OR CHARINDEX(CHAR(9), u.[AuthorityURL]) > 0
       OR CHARINDEX(CHAR(10), u.[AuthorityURL]) > 0
       OR CHARINDEX(CHAR(13), u.[AuthorityURL]) > 0
       OR CHARINDEX('<', u.[AuthorityURL]) > 0
       OR CHARINDEX('>', u.[AuthorityURL]) > 0
       OR CHARINDEX('"', u.[AuthorityURL]) > 0
       OR CHARINDEX('{', u.[AuthorityURL]) > 0
       OR CHARINDEX('}', u.[AuthorityURL]) > 0
       OR CHARINDEX('|', u.[AuthorityURL]) > 0
       OR CHARINDEX('\', u.[AuthorityURL]) > 0
       OR CHARINDEX('^', u.[AuthorityURL]) > 0
       OR CHARINDEX('`', u.[AuthorityURL]) > 0
       OR CHARINDEX('.', u.DomainName) = 0
       OR u.DomainName COLLATE Latin1_General_100_BIN2
          LIKE '%[^A-Za-z0-9.-]%'
       OR u.DomainName LIKE '.%'
       OR u.DomainName LIKE '%.'
       OR u.DomainName LIKE '-%'
       OR u.DomainName LIKE '%-'
       OR u.DomainName LIKE '%..%'
       OR u.DomainName LIKE '%.-%'
       OR u.DomainName LIKE '%-.%'
)
SELECT
    [CountryCode],
    [AuthorityInstanceId],
    [AuthorityRole],
    [Email],
    [AuthorityURL]
FROM CTE_invalid_urls;
GO


