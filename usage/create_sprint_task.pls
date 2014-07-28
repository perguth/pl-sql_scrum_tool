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
