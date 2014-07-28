/**
 * This will initialize the database after the import of the whole pl/sql-block
 * via command manager in pl/sql developer.
 */

exec insert_standardization_data();
exec insert_dummy_data();
-- to prevent double calling due to concatenation script
select 'initialized' from dual;
