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
