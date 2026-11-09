WITH CTE_authority AS
(
   SELECT
       "record_id",
        NULLIF("CountryCode", '')         AS CountryCode,
        NULLIF("AuthorityInstanceId", '') AS AuthorityInstanceId,
        NULLIF("AuthorityRole", '')       AS AuthorityRole,
        NULLIF("Email" '')               AS Email
   
    FROM dataset_112368."authority"
),
duplicate_auth_records AS
(
    SELECT
        "CountryCode",
        "AuthorityInstanceId",
        "AuthorityRole",
        "Email"
    FROM CTE_authority
    GROUP BY
        "CountryCode",
        "AuthorityInstanceId",
        "AuthorityRole",
        "Email"
    HAVING COUNT(*) > 1
)
SELECT
    a."record_id",
    a."CountryCode",
    a."AuthorityInstanceId",
    a."AuthorityRole",
    a."Email"
FROM CTE_authority AS a
LEFT JOIN duplicate_auth_records AS d
    ON  a."CountryCode" = d."CountryCode"
    AND a."AuthorityInstanceId" = d."AuthorityInstanceId"
    AND a."AuthorityRole" = d."AuthorityRole"
    AND a."Email" = d."Email"
WHERE
       d."CountryCode" IS NOT NULL
    OR a."CountryCode" IS NULL
    OR a."AuthorityInstanceId" IS NULL
    OR a."AuthorityRole" IS NULL
    OR a."Email" IS NULL