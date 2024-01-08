-- Creating a temporary table to store duplicates
-- This DOESNT WORK BECASUE THE SEARCH DOESNT IND ANY PAIRS THAT HAVE THE SAME AUTHOR AND TITLE WITH UNIQUE SOLD BY
SELECT *
INTO #duplicates
FROM (
    SELECT *,
           COUNT(*) OVER (PARTITION BY author, title) as duplicate_count
    FROM dbo.[kindle_data-v3]
) as subquery
WHERE duplicate_count > 1
ORDER BY author, title, publishedDate;


TRUNCATE TABLE rbook_fact;

DELETE FROM #duplicates
WHERE soldBy IS NULL;

WITH UniqueSoldByCounts AS (
    SELECT author,
           title,
           COUNT(DISTINCT soldBy) AS UniqueSoldByCount
    FROM #duplicates
    GROUP BY author, title
),
RankedDuplicates AS (
    SELECT d.*,
           RANK() OVER (PARTITION BY d.author, d.title ORDER BY d.publishedDate) AS DateRank,
           u.UniqueSoldByCount
    FROM #duplicates d
    INNER JOIN UniqueSoldByCounts u ON d.author = u.author AND d.title = u.title
)

,UpdatedTitles AS (
    SELECT *,
           CASE
               WHEN UniqueSoldByCount > 1 OR DateRank > 1 THEN title + ' ReEdition'
               ELSE title
           END AS UpdatedTitle
    FROM RankedDuplicates
)

SELECT author,
       UpdatedTitle AS title,
       asin,
       soldBy,
       stars,
       reviews,
       price,
       isKindleUnlimited,
       isBestSeller,
       isEditorsPick,
       isGoodReadsChoice,
       publishedDate,
       category_name
INTO #processed_duplicates
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY author, UpdatedTitle ORDER BY reviews DESC, stars DESC, DateRank) AS RowNum
    FROM UpdatedTitles
) AS Ranked
WHERE RowNum = 1;

DELETE k
FROM dbo.[kindle_data-v3] k
INNER JOIN #duplicates d
ON k.asin = d.asin;

-- Inserting processed duplicates back into the main table
INSERT INTO dbo.[kindle_data-v3]
SELECT * FROM #processed_duplicates;

IF OBJECT_ID('tempdb..#duplicates') IS NOT NULL
    DROP TABLE #duplicates;

IF OBJECT_ID('tempdb..#processed_duplicates') IS NOT NULL
    DROP TABLE #processed_duplicates;

SELECT *FROM dbo.[kindle_data-v3]
