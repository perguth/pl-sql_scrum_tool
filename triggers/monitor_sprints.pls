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
