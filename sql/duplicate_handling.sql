SELECT * INTO #main_temp from staging_v2

SELECT *
INTO #duplicates
FROM (
    SELECT *,
           COUNT(*) OVER (PARTITION BY author, title) as duplicate_count
    FROM #main_temp
) as subquery
WHERE duplicate_count > 1
ORDER BY  author, title;

-- Declare the variable
DECLARE @FirstCount INT;

-- Create a temporary table to store the results
-- Adjust the column definitions according to the structure of #duplicates
SELECT *
INTO #TempResults
FROM #duplicates
WHERE 1 = 0;

-- Declare a variables
DECLARE @SQLQuery NVARCHAR(MAX);
DECLARE @MaxReview INT, @MaxStar DECIMAL(3, 1), @MaxAsin VARCHAR(500);
DECLARE @IDsToDelete TABLE (asin varchar(500));
DECLARE @NumberedRows TABLE (
    asin VARCHAR(MAX), -- adjust the data type as needed
    RowNum INT
);
DECLARE @FirstAsin VARCHAR(MAX); -- adjust data type as needed
DECLARE @SecondAsin VARCHAR(MAX); -- adjust data type as needed
DECLARE @FirstSoldBy VARCHAR(MAX); -- adjust data type as needed
DECLARE @SecondSoldBy VARCHAR(MAX); -- adjust data type as needed
DECLARE @FirstPublishDate DATETIME; -- adjust data type as needed
DECLARE @SecondPublishDate DATETIME;

--Handle the special cases that have more than 2 duplicates
UPDATE #duplicates
SET duplicate_count = 2
WHERE duplicate_count = 4 AND soldBy = 'De Marque'

UPDATE #duplicates
SET duplicate_count = 2
WHERE duplicate_count = 4 AND soldBy = 'Amazon.com Services LLC'

UPDATE #duplicates
SET duplicate_count = 2
WHERE duplicate_count = 5 AND soldBy = 'De Marque'

UPDATE #duplicates
SET duplicate_count = 2
WHERE duplicate_count = 5 AND soldBy = 'Amazon.com Services LLC'

DELETE FROM #duplicates
WHERE asin = 'B076PZBTZK';

UPDATE #duplicates
SET duplicate_count = 2
WHERE duplicate_count = 5 AND soldBy = 'Amazon.com Services LLC' AND title='Exploring Psychology'

UPDATE #duplicates
SET title='Exploring Psychology - Re-Editon'
WHERE asin = 'B0BSP7DJ5Q'

UPDATE #duplicates
SET title='Wuthering Heights - Re-Editon II'
WHERE asin = 'B0BY7FFRCJ';

UPDATE #duplicates
SET title='Wuthering Heights - Re-Editon'
WHERE asin = 'B077711TRG';

UPDATE #duplicates
SET title='Legal and Ethical Issues for Health Professionals - Re-Editon II'
WHERE asin = 'B0BWSFRR49';

UPDATE #duplicates
SET title='Legal and Ethical Issues for Health Professionals - Re-Editon'
WHERE asin = 'B07KJMB439'

UPDATE #duplicates
SET title='1984 - Re-Editon II'
WHERE asin = 'B0CFQD9ZQH';

UPDATE #duplicates
SET title='Animal Farm - Re-Editon II'
WHERE asin = 'B0CD2FTLFB';

UPDATE #duplicates
SET title='Animal Farm - Re-Editon'
WHERE asin = 'B0C5FLKBWK';

UPDATE #duplicates
SET title='Automotive Technology: A Systems Approach - Re-Editon II'
WHERE asin = 'B07LH2X39B';

UPDATE #duplicates
SET title='Automotive Technology: A Systems Approach - Re-Editon'
WHERE asin = 'B00H7HV7AQ';

UPDATE #duplicates
SET title='War and Peace - Re-Editon II'
WHERE asin = 'B08NXSC6Z6';

UPDATE #duplicates
SET title='War And Peace - Re-Editon'
WHERE asin = 'B0C7TMQ95X';

UPDATE #duplicates
SET title='The U.S. Supreme Court: A Very Short Introduction (VERY SHORT INTRODUCTIONS) - Re-Editon II'
WHERE asin = 'B0CD4F26L6';

UPDATE #duplicates
SET title='The U.S. Supreme Court: A Very Short Introduction (VERY SHORT INTRODUCTIONS) - Re-Editon'
WHERE asin = 'B08761Z5K2';

UPDATE #duplicates
SET title='The Master and Margarita - Re-Editon II'
WHERE asin = 'B01DV1Y7D0';

UPDATE #duplicates
SET title='The Master and Margarita - Re-Editon'
WHERE asin = 'B0BFQRZ8DW';

UPDATE #duplicates
SET title='The Art Of War - Re-Editon'
WHERE asin = 'B0BW9W18HW';

UPDATE #duplicates
SET title='Advanced Practice Nursing: Essential Knowledge for the Profession - Re-Editon II'
WHERE asin = 'B0BS77B5L1';

UPDATE #duplicates
SET title='Advanced Practice Nursing: Essential Knowledge for the Profession - Re-Editon'
WHERE asin = 'B07XQSTCYP';

-- Decalre a variable to control the loop
DECLARE @Loop BIT;
SET @Loop = 1; -- Equivalent to True

-- Loop through the rows in #duplicates
WHILE @Loop = 1
    BEGIN

        SELECT TOP 1 @FirstCount = duplicate_count
        FROM #duplicates;


        -- Create a temporary table to store the results
-- Adjust the column definitions according to the structure of #duplicates

-- Construct the SQL query string
        SET @SQLQuery = 'INSERT INTO #TempResults SELECT TOP ' + CAST(@FirstCount AS NVARCHAR) + ' * FROM #duplicates';

-- Execute the SQL query
        EXECUTE sp_executesql @SQLQuery;

--IF BOTH ARE NULL IN SOLD_BY
        IF NOT EXISTS (SELECT 1 FROM #TempResults WHERE soldBy IS NOT NULL)
            BEGIN
                -- Find the row with the highest review and star values
                SELECT TOP 1 @MaxAsin = asin
                FROM #TempResults
                ORDER BY reviews Asc, stars Asc;

                -- Delete other rows from the main table that do not match the max value row
                DELETE
                FROM #main_temp
                WHERE asin = @MaxAsin;
            END


--IF ONLY ONE IS NULL IN SOLDBY
        IF (
            (SELECT COUNT(*) FROM #TempResults WHERE soldBy IS NULL) = 1
                AND
            (SELECT COUNT(*) FROM #TempResults WHERE soldBy IS NOT NULL) = 1
            )
            BEGIN
                -- Declare a table variable to store IDs of rows to be deleted
                -- Insert IDs of rows with NULL in 'sold_by' from #TempResults into @IDsToDelete
                INSERT INTO @IDsToDelete(asin)
                SELECT asin
                FROM #TempResults
                WHERE soldBy IS NULL;

                -- Delete rows from #main_temp where IDs match those in @IDsToDelete
                DELETE
                FROM #main_temp
                WHERE asin IN (SELECT asin FROM @IDsToDelete);

            END


        IF NOT EXISTS (SELECT 1 FROM #TempResults WHERE soldBy IS NULL)
            BEGIN
                INSERT INTO @NumberedRows (asin, RowNum)
                SELECT asin,
                       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
                FROM #TempResults;

                SELECT TOP 1 @FirstAsin = asin FROM @NumberedRows WHERE RowNum = 1;
                SELECT TOP 1 @SecondAsin = asin FROM @NumberedRows WHERE RowNum = 2;

                SELECT @FirstSoldBy = soldBy FROM #TempResults WHERE asin = @FirstAsin;
                SELECT @SecondSoldBy = soldBy FROM #TempResults WHERE asin = @SecondAsin;

                SELECT @FirstPublishDate = CONVERT(DATE, publishedDate) FROM #TempResults WHERE asin = @FirstAsin;
                SELECT @SecondPublishDate = CONVERT(DATE, publishedDate) FROM #TempResults WHERE asin = @SecondAsin;

                IF @FirstSoldBy = @SecondSoldBy
                    BEGIN

                        -- Check which publishDate is more recent and append -Rediton to its title
                        IF @FirstPublishDate > @SecondPublishDate
                            BEGIN
                                UPDATE #main_temp
                                SET title = title + ' Re-Editon'
                                WHERE asin = @FirstAsin;
                            END
                        ELSE
                            IF @SecondPublishDate > @FirstPublishDate
                                BEGIN
                                    UPDATE #main_temp
                                    SET title = title + ' Re-Editon'
                                    WHERE asin = @SecondAsin;
                                END
                    END

            END


        DELETE FROM #duplicates WHERE asin IN (SELECT asin FROM #TempResults);

        IF NOT EXISTS (SELECT 1 FROM #duplicates)
            BEGIN
                -- If #duplicates is empty, set @Loop to 0
                SET @Loop = 0;
            END

        DELETE FROM #TempResults
        DELETE FROM @NumberedRows;

    END

DELETE FROM staging_v2

INSERT INTO staging_v2
SELECT *
FROM #main_temp
ORDER BY title,author


IF OBJECT_ID('tempdb..#duplicates') IS NOT NULL
    DROP TABLE #duplicates;

IF OBJECT_ID('tempdb..#TempResults') IS NOT NULL
DROP TABLE #TempResults;

IF OBJECT_ID('tempdb..#main_temp') IS NOT NULL
DROP TABLE #main_temp;


UPDATE staging_v2
SET soldBy = 'Other'
WHERE soldBy IS NULL;
