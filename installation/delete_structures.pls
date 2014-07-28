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
