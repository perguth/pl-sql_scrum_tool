/**
 * This will create tables/constraints etc. Has to happen before triggers get
 * inserted or else inserting fails.
 */

exec create_structures();
