/**
 * This will drop the database before the import of the whole pl/sql-block
 * via command manager in pl/sql developer.
 */

clear;
SET SERVEROUTPUT ON SIZE 1000000;
exec delete_structures(); -- TODO: Problem with remaining tables?!
exec delete_structures();
