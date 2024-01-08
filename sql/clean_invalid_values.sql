BEGIN TRANSACTION; -- Start of the transaction

-- Delete rows where title is 'Not Found'
DELETE FROM staging_v2
WHERE title = 'Not Found';

-- Delete rows where author is NULL and title contains 'USER GUIDE'
DELETE FROM staging_v2
WHERE author IS NULL AND title LIKE '%USER GUIDE%';

-- Update rows where author is NULL to 'Other'
UPDATE staging_v2
SET author = 'Other'
WHERE author IS NULL;

COMMIT TRANSACTION; -- End of the transaction
