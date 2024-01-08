UPDATE staging_v2
SET soldBy = CASE
    WHEN LOWER(soldBy) LIKE '%amazon%' THEN 'Amazon.com'
    WHEN LOWER(soldBy) LIKE '%random house%' OR LOWER(soldBy) LIKE '%penguin%' THEN 'Penguin Random House'
    WHEN LOWER(soldBy) LIKE '%prh%' THEN 'Penguin Random House'
    WHEN LOWER(soldBy) LIKE '%rh%' THEN 'Penguin Random House'
    WHEN LOWER(soldBy) LIKE '%harpercollins%' OR LOWER(soldBy) LIKE '%harper collins%' THEN 'HarperCollins'
    WHEN LOWER(soldBy) LIKE '%simon%' THEN 'Simon & Schuster'
    WHEN LOWER(soldBy) LIKE '%macmillan%' THEN 'Macmillan'
    ELSE soldBy
END
