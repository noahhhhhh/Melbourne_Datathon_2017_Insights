;WITH Partitioned AS
(
    SELECT 
        ID,
        Name,
        ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Name) AS NameNumber,
        COUNT(*) OVER (PARTITION BY ID) AS NameCount
    FROM temp_txn_basket_raw
),
Concatenated AS
(
    SELECT ID, CAST(Name AS nvarchar(100)) AS FullName, Name, NameNumber, NameCount FROM Partitioned WHERE NameNumber = 1

    UNION ALL

    SELECT 
        P.ID, CAST(C.FullName + ', ' + P.Name AS nvarchar(100)), P.Name, P.NameNumber, P.NameCount
    FROM Partitioned AS P
        INNER JOIN Concatenated AS C ON P.ID = C.ID AND P.NameNumber = C.NameNumber + 1
)
SELECT 
    ID as TRANSACTION_ID,
    FullName as DRUGS
INTO
	temp_txn_basket_drugs
FROM Concatenated
WHERE NameNumber = NameCount