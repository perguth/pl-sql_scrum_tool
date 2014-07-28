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
