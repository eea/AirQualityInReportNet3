USE [Airquality_R3]
GO

/****** Object:  View [qc].[DOC_06_A]    Script Date: 01/09/2026 12:27:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[DOC_06_A]
AS
-- QC rule code: DOC_06_A
-- QC rule name: Format validation - [DocumentOriginalURL]
--
-- Returns Documentation records where DocumentOriginalURL does not
-- satisfy the basic HTTP/HTTPS URL syntax requirements.
--
-- Note: SQL Server cannot fully validate RFC URL syntax or verify
-- that the URL is reachable. This validation checks protocol, host,
-- spaces, invalid characters and basic domain-name structure.

WITH CTE_documentation AS
(
    SELECT
        [CountryCode],
        [DataTable],
        [DocumentType],
        [DocumentId],
        [DocumentOriginalURL] AS [DocumentOriginalURLRaw],
        NULLIF(LTRIM(RTRIM([DocumentOriginalURL])), '')
            AS [DocumentOriginalURL]
    FROM [reporting].[Documentation]
),
CTE_url_parts AS
(
    SELECT
        d.[CountryCode],
        d.[DataTable],
        d.[DocumentType],
        d.[DocumentId],
        d.[DocumentOriginalURLRaw],
        d.[DocumentOriginalURL],

        CASE
            WHEN d.[DocumentOriginalURL] LIKE 'http://%'
                THEN 8
            WHEN d.[DocumentOriginalURL] LIKE 'https://%'
                THEN 9
            ELSE NULL
        END AS [ProtocolLength]
    FROM CTE_documentation AS d
),
CTE_host_parts AS
(
    SELECT
        u.*,

        CASE
            WHEN u.[ProtocolLength] IS NOT NULL
                THEN SUBSTRING
                (
                    u.[DocumentOriginalURL],
                    u.[ProtocolLength] + 1,
                    LEN(u.[DocumentOriginalURL])
                )
            ELSE NULL
        END AS [UrlAfterProtocol]
    FROM CTE_url_parts AS u
),
CTE_domain_parts AS
(
    SELECT
        h.*,

        CASE
            WHEN h.[UrlAfterProtocol] IS NOT NULL
             AND PATINDEX('%[/?#]%', h.[UrlAfterProtocol]) > 0
                THEN LEFT
                (
                    h.[UrlAfterProtocol],
                    PATINDEX('%[/?#]%', h.[UrlAfterProtocol]) - 1
                )
            ELSE h.[UrlAfterProtocol]
        END AS [DomainName]
    FROM CTE_host_parts AS h
)
SELECT
    [CountryCode],
    [DataTable],
    [DocumentType],
    [DocumentId],
    [DocumentOriginalURLRaw] AS [DocumentOriginalURL],
    [DomainName],
    CASE
        -- URL is mandatory.
        WHEN [DocumentOriginalURL] IS NULL
            THEN 'MISSING_OR_EMPTY_URL'

        -- Only HTTP and HTTPS protocols are accepted.
        WHEN [ProtocolLength] IS NULL
            THEN 'INVALID_OR_MISSING_PROTOCOL'

        -- A domain must be present after the protocol.
        WHEN [DomainName] IS NULL
          OR [DomainName] = ''
            THEN 'MISSING_DOMAIN'

        -- A domain name must contain at least one dot.
        WHEN CHARINDEX('.', [DomainName]) = 0
            THEN 'INVALID_DOMAIN'

        -- Dots and hyphens cannot appear at the beginning or end.
        WHEN [DomainName] LIKE '.%'
          OR [DomainName] LIKE '%.'
          OR [DomainName] LIKE '-%'
          OR [DomainName] LIKE '%-'
          OR [DomainName] LIKE '%..%'
            THEN 'INVALID_DOMAIN'

        -- Spaces and characters that are not allowed in a standard URL.
        WHEN [DocumentOriginalURL] COLLATE Latin1_General_100_BIN2
             LIKE '%[ ' + CHAR(9) + CHAR(10) + CHAR(13) + '<>"{}|\\^]%'
            THEN 'INVALID_URL_CHARACTERS'

        -- The host must not include a port separator, user info, or query syntax.
        -- These are not accepted by this simplified domain validation.
        WHEN [DomainName] LIKE '%:%'
          OR [DomainName] LIKE '%@%'
          OR [DomainName] LIKE '%?%'
          OR [DomainName] LIKE '%#%'
            THEN 'INVALID_DOMAIN'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_domain_parts
WHERE
    [DocumentOriginalURL] IS NULL
    OR [ProtocolLength] IS NULL
    OR [DomainName] IS NULL
    OR [DomainName] = ''
    OR CHARINDEX('.', [DomainName]) = 0
    OR [DomainName] LIKE '.%'
    OR [DomainName] LIKE '%.'
    OR [DomainName] LIKE '-%'
    OR [DomainName] LIKE '%-'
    OR [DomainName] LIKE '%..%'
    OR [DocumentOriginalURL] COLLATE Latin1_General_100_BIN2
       LIKE '%[ ' + CHAR(9) + CHAR(10) + CHAR(13) + '<>"{}|\\^]%'
    OR [DomainName] LIKE '%:%'
    OR [DomainName] LIKE '%@%'
    OR [DomainName] LIKE '%?%'
    OR [DomainName] LIKE '%#%';
GO


