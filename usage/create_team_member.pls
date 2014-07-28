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
