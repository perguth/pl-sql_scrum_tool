select * from team_members;
call create_sprint('14.02.2015', 1);
call create_sprint_task(1, 'Mache x.', 'tom', 'backlog', 'None');
select * from backlog_items;
select * from activity_log_entries;
