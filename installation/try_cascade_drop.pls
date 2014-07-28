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
