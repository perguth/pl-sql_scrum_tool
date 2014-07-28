/**
 * Create a virtual schema on which insert-statements in procedures can depend
 * so that we can migrate the real schema more easily.
 */

----------------------------------------------------------
-- schema 01
----------------------------------------------------------
-- create table product_backlogs ( -- table, t#1
--  id int primary key,
--  description varchar (4000),
--  active char (1) check (active in ('y', 'n')),
--  owner int not null -- foreign key, fk#1
-- )
----------------------------------------------------------


create or replace view s01_product_backlogs as
select id, description, active, owner
from product_backlogs -- does not allow semicolon?!
