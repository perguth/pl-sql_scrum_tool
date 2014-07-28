------------------------------------------------------
-- id int primary key,
-- description varchar (4000),
-- sprint int not null, -- foreign key, fk#12
-- approved char (1) check (approved in ('y', 'n')),
-- done char (1) check (done in ('y', 'n')),
-- ship char (1) check (ship in ('y', 'n')),
-- acceptance_criteria varchar (4000),
-- effort int not null -- foreign key, fk#9
------------------------------------------------------
create or replace procedure create_backlog_item
  (
    description varchar2,
    product_backlog_id number,
    is_appoved varchar2,
    acceptance_criteria varchar2,
    effort_size varchar2
  )
is
  approved char(1) := 'n';
  effort_id int;
  done char(1) := 'n';
  ship char(1) := 'n';
  fk_violation exception;
  pragma exception_init(fk_violation, -2291);
begin
  -- parse is_approved
  if is_appoved = 'yes' then approved := 'y'; end if;
  -- find id to effort_size string
  execute immediate (
    q'{ select id from scrum_terms where term = '}' ||
    effort_size ||
    q'{'}'
  ) into effort_id;
  --
  insert into backlog_items values (
    b_items_id.nextval,
    description,
    product_backlog_id,
    approved,
    done,
    ship,
    acceptance_criteria,
    effort_id
  );
  commit;
exception
  when fk_violation then
    dbms_output.put_line(
      'Something went wrong. Maybe check if you use correct terms and IDs?'
    );
end;
