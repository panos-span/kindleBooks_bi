INSERT INTO author_dim (label_author) SELECT DISTINCT [author] FROM staging_v2;

INSERT INTO category_dim (label_category) SELECT DISTINCT [category_name] FROM staging_v2;

INSERT INTO soldBy_dim (label_soldBy)
SELECT DISTINCT [soldBy]
FROM staging_v2
WHERE [soldBy] IS NOT NULL;

INSERT INTO pdate_dim (label_publishedDate, label_year, label_month, label_monthName, label_decade)
SELECT
    DISTINCT publishedDate,
    YEAR(publishedDate) AS year,
    MONTH(publishedDate) AS month,
    DATENAME(MONTH, publishedDate) AS monthName,
    (YEAR(publishedDate) / 10) * 10 AS decade
FROM
    staging_v2
WHERE
    publishedDate IS NOT NULL;

INSERT INTO book_dim (label_title, label_reviews,label_isKindleUnlimited, label_isBestSeller, label_isEditorsPick, label_isGoodReadsChoice)
SELECT
    DISTINCT title,
    reviews,
    isKindleUnlimited,
    isBestSeller,
    isEditorsPick,
    isGoodReadsChoice
FROM
    staging_v2;