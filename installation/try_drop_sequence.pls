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
