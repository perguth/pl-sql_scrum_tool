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
