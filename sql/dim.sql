INSERT INTO author_dim (label_author) SELECT DISTINCT [author] FROM staging_v2;

INSERT INTO category_dim (label_category) SELECT DISTINCT [category_name] FROM staging_v2;

INSERT INTO soldBy_dim (label_soldBy) SELECT DISTINCT [soldBy] FROM staging_v2;

INSERT INTO pdate_dim (label_publishedDate, label_year, label_month, label_monthName)
SELECT
    DISTINCT publishedDate,
    YEAR(publishedDate) AS year,
    MONTH(publishedDate) AS month,
    DATENAME(MONTH, publishedDate) AS monthName
FROM
    staging_v2
WHERE
    publishedDate IS NOT NULL;

INSERT INTO book_dim (label_title, label_reviews, label_price,label_isKindleUnlimited, label_isBestSeller, label_isEditorsPick, label_isGoodReadsChoice)
SELECT
    DISTINCT title,
    reviews,
    price,
    isKindleUnlimited,
    isBestSeller,
    isEditorsPick,
    isGoodReadsChoice
FROM
    staging_v2;

SELECT stars
    FROM staging_v2;

TRUNCATE TABLE rbook_fact;


INSERT INTO rbook_fact (Book, Author, PublishedDate, Category, SoldBy, Rating)
SELECT
    b.id_book AS Book,
    a.id_author AS Author,
    p.id_date AS PublishedDate,
    c.id_category AS Category,
    s.id_soldBy AS SoldBy,
    stg.stars AS Rating
FROM
    staging_v2 stg
INNER JOIN book_dim b ON stg.title = b.label_title
INNER JOIN author_dim a ON stg.author = a.label_author
INNER JOIN pdate_dim p ON stg.publishedDate = p.label_publishedDate
INNER JOIN category_dim c ON stg.category_name = c.label_category
INNER JOIN soldBy_dim s ON stg.soldBy = s.label_soldBy

/* Add new column float price */
ALTER TABLE rbook_fact
ADD price FLOAT;
TRUNCATE TABLE rbook_fact;

/* Remove column price from book_dim */
ALTER TABLE book_dim
DROP COLUMN label_price;

/* Make the price column in rbook_fact be not null */
ALTER TABLE rbook_fact
ALTER COLUMN price FLOAT NOT NULL;

TRUNCATE TABLE staging_v2;

TRUNCATE TABLE author_dim;
TRUNCATE TABLE category_dim;
TRUNCATE TABLE soldBy_dim;
TRUNCATE TABLE pdate_dim;
TRUNCATE TABLE book_dim;
TRUNCATE TABLE rbook_fact;

ALTER TABLE staging_v2
ALTER COLUMN title NVARCHAR(400);

ALTER TABLE staging_v2
ALTER COLUMN asin NVARCHAR(10);

ALTER TABLE staging_v2
ALTER COLUMN author NVARCHAR(200);

ALTER TABLE staging_v2
ALTER COLUMN publishedDate DATE;

ALTER TABLE pdate_dim
ALTER COLUMN label_decade INT;

ALTER TABLE staging_v2
ALTER COLUMN category_name NVARCHAR(40);

ALTER TABLE staging_v2
ALTER COLUMN soldBy NVARCHAR(200);

TRUNCATE TABLE staging_v2;

ALTER TABLE staging_v2
ALTER COLUMN title VARCHAR(400);

ALTER TABLE staging_v2
ALTER COLUMN author VARCHAR(200);

ALTER TABLE staging_v2
ALTER COLUMN category_name VARCHAR(40);

ALTER TABLE staging_v2
ALTER COLUMN soldBy VARCHAR(200);

ALTER TABLE staging_v2
ALTER COLUMN reviews BIGINT;
