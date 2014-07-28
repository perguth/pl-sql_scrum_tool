/**
 * Created by:
 *   Per Guth <mail@perguth.de> (https://perguth.de/)
 *   Johannes-C. J. Hilbert <mckollin.john@gmail.com>
 *
 * Licensed under AGPLv3
 */
 -- 
 -- ## Installation
 -- 
 -- Open a `Command Window` or `SQL*Plus`. Copy and paste the complete contents of this file (`concat.pls`).
 -- 
 -- For first steps take a look into `test_functionality.sql`.

 /**
 * This will drop the database before the import of the whole pl/sql-block
 * via command manager in pl/sql developer.
 */

clear;
SET SERVEROUTPUT ON SIZE 1000000;
exec delete_structures(); -- TODO: Problem with remaining tables?!
exec delete_structures();
/
/**
 * All SQL statements are collected in an array and then fired one after the
 * other at the end. Also 'table exists' exceptions are captured and advice is
 * given in an output.
 *
 */

--------------------------------------------------------------------------------
create or replace procedure create_structures is
  table_exists exception;
  pragma exception_init(table_exists, -955);
  type array_t is varray(100) of varchar2(4000);
  tables array_t := array_t(
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CREATE TABLES start ---------------------------------------------------------
--------------------------------------------------------------------------------
-- product_backlogs       t#1
-- backlog_items          t#2
-- sprints                t#3
-- sprint_tasks           t#4
-- team_members           t#5
-- activity_log_entries   t#6
-- scrum_terms            t#7
-- countries              t#8
-- b_item_sprint_maps     t#9
-- sprint_s_task_maps     t#10
--
-- with foreign key constraints fk#1 till fk#9
--------------------------------------------------------------------------------
q'{

  create table product_backlogs ( -- table, t#1
    id int primary key,
    description varchar (4000),
    active char (1) check (active in ('y', 'n')),
    owner int not null, -- foreign key, fk#1
    value float (4) -- new in schema 02
  )

}', q'{

  create sequence p_backlogs_id start with 1 increment by 1

}', q'{

  create table backlog_items ( -- table, t#2
    id int primary key,
    description varchar (4000),
    product_backlog int not null, -- foreign key, fk#2
    approved char (1) check (approved in ('y', 'n')),
    done char (1) check (done in ('y', 'n')),
    ship char (1) check (ship in ('y', 'n')),
    acceptance_criteria varchar (4000),
    effort int not null -- foreign key, fk#9
  )

}', q'{

  create sequence b_items_id start with 1 increment by 1

}', q'{

  create table sprints ( -- table, t#3
    id int primary key,
    due_date date not null
  )

}', q'{

  create sequence sprints_id start with 1 increment by 1

}', q'{

  create table sprint_tasks ( -- table, t#4
    id int primary key,
    description varchar (4000),
    point_person int, -- foreign key, fk#4
    status int not null, -- foreign key, #5
    impediments varchar (4000)
  )

}', q'{

  create sequence s_tasks_id start with 1 increment by 1

}', q'{

  create table team_members ( -- table, t#5
    id int primary key,
    username varchar (32) not null,
    current_location int not null -- foreign key, fk#8
  )

}', q'{

  create sequence t_members_id start with 1 increment by 1

}', q'{

  create table activity_log_entries ( -- table, t#6
    id int primary key,
    operation int not null, -- foreign key, fk#7
    time_stamp timestamp,
    table_name varchar (32),
    row_id int not null
  )

}', q'{

  create sequence activity_log_entries_id start with 1 increment by 1

}', q'{

  create table scrum_terms ( -- table, t#7
    id int primary key,
    term varchar (32)
  )

}', q'{

  create sequence s_terms_id start with 1 increment by 1

}', q'{

  create table countries ( -- table t#8
    id int primary key,
    name varchar (100) not null,
    code varchar (2) not null
  )

}', q'{

  create sequence countries_id start with 1 increment by 1

}',
-- MAP TABLES start ------------------------------------------------------------
q'{

  create table b_item_sprint_maps ( -- table, t#9
    id int primary key,
    backlog_item_id int references backlog_items (id),
    sprint_id int references sprints (id)
  )

}', q'{

  create sequence b_item_sprint_maps_id start with 1 increment by 1

}', q'{

  create table sprint_s_task_maps ( -- table, t#10
    id int primary key,
    sprint_id int references sprints (id),
    sprint_task_id int references sprint_tasks (id)
  )

}', q'{

  create sequence sprint_s_task_maps_id start with 1 increment by 1

}',
--------------------------------------------------------------------------------
-- ADD CONSTRAINTS start -------------------------------------------------------
--------------------------------------------------------------------------------
q'{
  alter table product_backlogs --> for fk#1
    add constraint p_backlogs_owner_fk
    foreign key (owner) references team_members (id)

}', q'{

  alter table backlog_items --> for fk#2
    add constraint b_items_product_backlog_fk
    foreign key (product_backlog) references product_backlogs (id)

}', q'{

  alter table sprint_tasks --> for fk#4
    add constraint s_tasks_point_person_fk
    foreign key (point_person) references team_members (id)

}', q'{

  alter table sprint_tasks --> for fk#5
    add constraint s_tasks_status_fk
    foreign key (status) references scrum_terms (id)

}', q'{

  alter table activity_log_entries --> for fk#7
    add constraint a_l_entries_operation_fk
    foreign key (operation) references scrum_terms (id)

}', q'{

  alter table team_members --> for fk#8
    add constraint t_members_current_location_fk
    foreign key (current_location) references countries (id)

}', q'{

  alter table backlog_items --> for fk#9
    add constraint b_items_effort_fk
    foreign key (effort) references scrum_terms (id)

}');
--------------------------------------------------------------------------------
-- SQL END ---------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
begin
  for i in 1..tables.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    execute immediate tables(i);
  end loop;
  commit;
exception
  when table_exists
    then dbms_output.put_line(
      replace(
        'One of the tables exists. Try dropping old tables using "call
drop_tables()" first!', chr(10), ''
      )
    );
end;
/
create or replace procedure delete_structures
is
  type array_t is varray(32)
             of varchar2(32);
  tables array_t := array_t(

--------------------------------------------------------------------------------
--- TABLE LIST start -----------------------------------------------------------

    'product_backlogs', -- t#1
    'backlog_items', -- t#2
    'sprints', -- t#3
    'sprint_tasks', -- t#4
    'team_members', -- t#5
    'activity_log_entries', -- t#6
    'scrum_terms', -- t#7
    'countries', -- t#8
    'b_item_sprint_maps', -- t#9
    'sprint_s_task_maps', -- t#10
    'sprint_t_member_maps', -- t#11
    'log_workarounds' -- t#12

--- TABLE LIST end -------------------------------------------------------------
--------------------------------------------------------------------------------

  );
  sequences array_t := array_t(

--------------------------------------------------------------------------------
--- SEQUENCE LIST start --------------------------------------------------------

    'p_backlogs_id',
    'b_items_id',
    'sprints_id',
    's_tasks_id',
    't_members_id',
    'activity_log_entries_id',
    's_terms_id',
    'countries_id',
    'l_workarounds_id',
    'b_item_sprint_maps_id',
    'sprint_s_task_maps_id'

--- SEQUENCE LIST end ----------------------------------------------------------
--------------------------------------------------------------------------------

  );
begin
  dbms_output.put_line('Starting to drop tables...');
  for i in 1..tables.count loop
    if try_cascade_drop(tables(i)) then
      dbms_output.put_line('Dropped: ' || tables(i));
    else
      dbms_output.put_line('Table "' || tables(i) || '" did *not* exist.');
    end if;
  end loop;
  commit;
  for i in 1..sequences.count loop
    if try_drop_sequence(sequences(i)) then
      dbms_output.put_line('Dropped sequence: ' || sequences(i));
    else
      dbms_output.put_line('Sequence "' || sequences(i) ||
        '" did *not* exist.');
    end if;
  end loop;
  commit;
end;
/
create or replace procedure insert_dummy_data
is
  type array_t is varray(100) of varchar2(256);
  ------------------------------------
  ------------------------------------
  -- create_team_member()
  ------------------------------------
  team_members array_t := array_t(
    'tom',
      'de',
      --
    'frank',
      'us'
  );
  ------------------------------------
  ------------------------------------
  -- create_backog()
  ------------------------------------
  product_backlogs array_t := array_t(
    'frank',
      'Ein etwas weniger gutes Produkt mit noch mehr Eigenschaften.',
      'n',
      'tom',
      --
    'tom',
      'Mein disruptives Produkt mit Eigenschaften!',
      'y',
      'frank'
  );
  ------------------------------------
  ------------------------------------
  -- create_backog_item()
  ------------------------------------
  backlog_items array_t := array_t(
    'Es soll alles auf einmal können.',
      1,
      'yes',
      'Es soll die Investoren umhauen!',
      'extra large',
      --
    'Es soll beim rollen tönen.',
      2,
      'yes',
      'Beim Test im Büro.',
      'medium',
      --
    'Es soll zufällig leuchten.',
      2,
      'yes',
      'Im Dunkeln testen.',
      'small',
      --
    'Es kann fliegen.',
      2,
      'no',
      'Im Freien testen.',
      'large'
  );
  --
begin
  for i in 1..team_members.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    if i mod 2 = 1 then
      create_team_member(
        team_members(i),
        team_members(i+1)
      );
    end if;
  end loop;
  for i in 1..product_backlogs.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    if i mod 4 = 1 then
      create_product_backlog(
        product_backlogs(i),
        product_backlogs(i+1),
        product_backlogs(i+2),
        product_backlogs(i+3)
      );
    end if;
  end loop;
  for i in 1..backlog_items.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    if i mod 5 = 1 then
      create_backlog_item(
        backlog_items(i),
        backlog_items(i+1),
        backlog_items(i+2),
        backlog_items(i+3),
        backlog_items(i+4)
      );
    end if;
  end loop;
  commit;
end;
/
create or replace procedure insert_standardization_data
is
  type array_t is varray(100) of varchar2(12000);
  tables array_t := array_t(
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- scrum terms -----------------------------------------------------------------
--------------------------------------------------------------------------------

-- static pl/sql insert does not provide a shorthand for multiple inserts
-- thus regular sql:
q'{

  insert all
    -- [sprint_tasks: status]
      into scrum_terms values (1, 'backlog')
      into scrum_terms values (2, 'not started')
      into scrum_terms values (3, 'in progress')
      into scrum_terms values (4, 'completed')

    -- [activity_log_entries: what]
      into scrum_terms values (5, 'insert')
      into scrum_terms values (6, 'update')
      into scrum_terms values (7, 'delete')

    -- [activity_log_entries: where_table]
      into scrum_terms values (8, 'product_backlogs')
      into scrum_terms values (9, 'backlog_items')
      into scrum_terms values (10, 'sprints')
      into scrum_terms values (11, 'sprint_tasks')
      into scrum_terms values (12, 'team_members')

    -- [backlog_items: effort]
      into scrum_terms values (13, 'small')
      into scrum_terms values (14, 'medium')
      into scrum_terms values (15, 'large')
      into scrum_terms values (16, 'extra large')
  select * from dual

}',
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- country code etc ------------------------------------------------------------
--------------------------------------------------------------------------------
-- source: http://java.sg/sql-script-for-country-table-ddl-and-dml/
--------------------------------------------------------------------------------
q'{

  insert all
    into countries values (1, 'Germany', 'DE')
    into countries values (2, 'United States', 'US')
    into countries values (3, 'China', 'CN')
    into countries values (4, 'Singapore', 'SG')
  select * from dual

}');

begin
  dbms_output.put_line('Inserting standardization table data.');
  for i in 1..tables.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    execute immediate tables(i);
  end loop;
  commit;
end;
/
create or replace function try_cascade_drop (table_name varchar2)
return boolean is
  does_not_exist exception;
  pragma exception_init(does_not_exist, -942);
begin
  execute immediate ('drop table ' || table_name || ' cascade constraints');
  return true;
exception
  when does_not_exist
    then return false;
end;
/
create or replace function try_drop_sequence (sequence_name varchar2)
return boolean is
  does_not_exist exception;
  pragma exception_init(does_not_exist, -2289);
begin
  execute immediate ('drop sequence ' || sequence_name);
  return true;
exception
  when does_not_exist
    then return false;
end;
/
/**
 * This will create tables/constraints etc. Has to happen before triggers get
 * inserted or else inserting fails.
 */

exec create_structures();
/
create or replace trigger monitor_b_items
after insert or update or delete on backlog_items
for each row
declare
  table_name varchar(32) := 'backlog_items';
  operation_id number;
begin
  ----------------------------------------------
  -- log table layout
  ----------------------------------------------
  -- id int primary key,
  -- operation int not null, -- foreign key, fk#7
  -- time_stamp timestamp,
  -- table_name varchar (32),
  -- row_id int not null
  ----------------------------------------------

  if INSERTING then
    operation_id := 5;
  end if;
  if UPDATING then
    operation_id := 6;
  end if;
  if DELETING then
    operation_id := 7;
  end if;

  insert into activity_log_entries values (
    activity_log_entries_id.nextval,
    operation_id,
    systimestamp,
    table_name,
    :NEW.id
  );
end;
/
create or replace trigger monitor_p_backlogs
after insert or update or delete on product_backlogs
for each row
declare
  table_name varchar(32) := 'product_backlogs';
  operation_id number;
begin
  ----------------------------------------------
  -- log table layout
  ----------------------------------------------
  -- id int primary key,
  -- operation int not null, -- foreign key, fk#7
  -- time_stamp timestamp,
  -- table_name varchar (32),
  -- row_id int not null
  ----------------------------------------------

  if INSERTING then
    operation_id := 5;
  end if;
  if UPDATING then
    operation_id := 6;
  end if;
  if DELETING then
    operation_id := 7;
  end if;

  insert into activity_log_entries values (
    activity_log_entries_id.nextval,
    operation_id,
    systimestamp,
    table_name,
    :NEW.id
  );
end;
/
create or replace trigger monitor_s_items
after insert or update or delete on sprints_items
for each row
declare
  table_name varchar(32) := 'sprints_items';
  operation_id number;
begin
  ----------------------------------------------
  -- log table layout
  ----------------------------------------------
  -- id int primary key,
  -- operation int not null, -- foreign key, fk#7
  -- time_stamp timestamp,
  -- table_name varchar (32),
  -- row_id int not null
  ----------------------------------------------

  if INSERTING then
    operation_id := 5;
  end if;
  if UPDATING then
    operation_id := 6;
  end if;
  if DELETING then
    operation_id := 7;
  end if;

  insert into activity_log_entries values (
    activity_log_entries_id.nextval,
    operation_id,
    systimestamp,
    table_name,
    :NEW.id
  );
end;
/
create or replace trigger monitor_sprints
after insert or update or delete on sprints
for each row
declare
  table_name varchar(32) := 'sprints';
  operation_id number;
begin
  ----------------------------------------------
  -- log table layout
  ----------------------------------------------
  -- id int primary key,
  -- operation int not null, -- foreign key, fk#7
  -- time_stamp timestamp,
  -- table_name varchar (32),
  -- row_id int not null
  ----------------------------------------------

  if INSERTING then
    operation_id := 5;
  end if;
  if UPDATING then
    operation_id := 6;
  end if;
  if DELETING then
    operation_id := 7;
  end if;

  insert into activity_log_entries values (
    activity_log_entries_id.nextval,
    operation_id,
    systimestamp,
    table_name,
    :NEW.id
  );
end;
/
------------------------------------------------------
-- id int primary key,
-- description varchar (4000),
-- sprint int not null, -- foreign key, fk#12
-- approved char (1) check (approved in ('y', 'n')),
-- done char (1) check (done in ('y', 'n')),
-- ship char (1) check (ship in ('y', 'n')),
-- acceptance_criteria varchar (4000),
-- effort int not null -- foreign key, fk#9
------------------------------------------------------
create or replace procedure create_backlog_item
  (
    description varchar2,
    product_backlog_id number,
    is_appoved varchar2,
    acceptance_criteria varchar2,
    effort_size varchar2
  )
is
  approved char(1) := 'n';
  effort_id int;
  done char(1) := 'n';
  ship char(1) := 'n';
  fk_violation exception;
  pragma exception_init(fk_violation, -2291);
begin
  -- parse is_approved
  if is_appoved = 'yes' then approved := 'y'; end if;
  -- find id to effort_size string
  execute immediate (
    q'{ select id from scrum_terms where term = '}' ||
    effort_size ||
    q'{'}'
  ) into effort_id;
  --
  insert into backlog_items values (
    b_items_id.nextval,
    description,
    product_backlog_id,
    approved,
    done,
    ship,
    acceptance_criteria,
    effort_id
  );
  commit;
exception
  when fk_violation then
    dbms_output.put_line(
      'Something went wrong. Maybe check if you use correct terms and IDs?'
    );
end;
/
------------------------------------------------------
-- id int primary key,
-- description varchar (4000),
-- active char (1) check (active in ('y', 'n')),
-- owner int not null -- foreign key, fk#1
------------------------------------------------------
create or replace procedure create_product_backlog
  (
    as_member varchar2,
    description varchar2,
    is_active varchar2,
    owner_name varchar2)
is
  owner_id number;
  active char(1);
  fk_violation exception;
  pragma exception_init(fk_violation, -2291);
begin
  active := 'n';

  -- TODO: check if user is admin and is allowed

  -- find owner id by name
  execute immediate (
    q'{select id from team_members where username = '}' ||
    owner_name ||
    q'{'}'
  ) into owner_id;

  -- parse is_active
  if is_active = 'yes' then active := 'y'; end if;

  insert into s01_product_backlogs values (
    p_backlogs_id.nextval,
    description,
    active,
    owner_id
  );
  commit;
exception
  when fk_violation then
    dbms_output.put_line(
      'Something went wrong. Maybe check if the owner really exists?'
    );
end;
/
------------------------------------------------------
-- id int primary key,
-- backlog_item int not null, -- foreign key, fk#11
-- due_date date,
-- coach int not null -- foreign key, fk#10
------------------------------------------------------
create or replace procedure create_sprint
  (
    due_date varchar2,
    backlog_item number
  )
is
begin
  insert into sprints values (
    sprints_id.nextval,
    to_date(due_date, 'DD.MM.YYYY')
  );
  -- also create join table
  insert into b_item_sprint_maps values (
    b_item_sprint_maps_id.nextval,
    backlog_item,
    sprints_id.currval
  );
  commit;
exception
  when others then
    dbms_output.put_line(
      'Something went wrong. Maybe check if IDs are correct and the date is
"DD.MM.YYYY"?'
    );
    -- TODO: re-raise to let exception bubble up
end;
/
------------------------------------------------------
-- id int primary key,
-- sprint int not null, -- foreign key, fk#12
-- description varchar (4000),
-- point_person int not null, -- foreign key, fk#4
-- status int not null, -- foreign key, #5
-- impediments varchar (4000)
------------------------------------------------------
create or replace procedure create_sprint_task
  (
    sprint number,
    description varchar2,
    point_person_name varchar2,
    status varchar2,
    impediments varchar2
  )
is
  point_person_id int;
  status_term_id int;
begin
  -- find point_person id through name
  execute immediate (
    q'{ select id from team_members where username = '}' ||
    point_person_name ||
    q'{'}'
  ) into point_person_id;
  --
  -- find status id through name
  execute immediate (
    q'{ select id from scrum_terms where term = '}' ||
    status ||
    q'{'}'
  ) into status_term_id;
  --
  insert into sprint_tasks values (
    s_tasks_id.nextval,
    description,
    point_person_id,
    status_term_id,
    impediments
  );
  -- also add join table
  insert into sprint_s_task_maps values (
    sprint_s_task_maps_id.nextval,
    sprint,
    s_tasks_id.currval
  );
  commit;
exception
  when others then
    dbms_output.put_line(
      'Something went wrong. Maybe check if IDs are correct and point person
exists?'
    );
    -- TODO: re-raise to let exception bubble up
end;
/
------------------------------------------------------
-- id int primary key,
-- username varchar (32) not null,
-- internal_id int not null,
-- current_location int not null -- foreign key, fk#8
------------------------------------------------------
create or replace procedure create_team_member
  (
    username varchar,
    country_code varchar2
  )
is
  country_id number;
begin
  -- find country id by code
  execute immediate (
    q'{select id from countries where code = '}' ||
    upper(country_code) ||
    q'{'}'
  ) into country_id;
  -- TODO: check if username is admin and can perform add
  insert into team_members values (
    t_members_id.nextval,
    username,
    country_id
  );
  commit;
end;
/
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
/
/**
 * This will initialize the database after the import of the whole pl/sql-block
 * via command manager in pl/sql developer.
 */

exec insert_standardization_data();
exec insert_dummy_data();
-- to prevent double calling due to concatenation script
select 'initialized' from dual;
/