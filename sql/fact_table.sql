TRUNCATE TABLE rbook_fact;
INSERT INTO rbook_fact (Book, Author, PublishedDate, Category, SoldBy, Rating, price)
SELECT
    b.id_book AS Book,
    a.id_author AS Author,
    p.id_date AS PublishedDate,
    c.id_category AS Category,
    s.id_soldBy AS SoldBy,
    stg.stars AS Rating,
    stg.price AS price
FROM
    staging_v2 stg
INNER JOIN book_dim b ON stg.title = b.label_title
INNER JOIN author_dim a ON stg.author = a.label_author
INNER JOIN pdate_dim p ON stg.publishedDate = p.label_publishedDate
INNER JOIN category_dim c ON stg.category_name = c.label_category
INNER JOIN soldBy_dim s ON stg.soldBy = s.label_soldBy
