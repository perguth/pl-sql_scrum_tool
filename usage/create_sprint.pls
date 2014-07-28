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
