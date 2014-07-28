create or replace procedure insert_dummy_data
is
  type array_t is varray(100) of varchar2(256);
  ------------------------------------
  ------------------------------------
  -- create_team_member()
  ------------------------------------
  team_members array_t := array_t(
    'tom',
      'de',
      --
    'frank',
      'us'
  );
  ------------------------------------
  ------------------------------------
  -- create_backog()
  ------------------------------------
  product_backlogs array_t := array_t(
    'frank',
      'Ein etwas weniger gutes Produkt mit noch mehr Eigenschaften.',
      'n',
      'tom',
      --
    'tom',
      'Mein disruptives Produkt mit Eigenschaften!',
      'y',
      'frank'
  );
  ------------------------------------
  ------------------------------------
  -- create_backog_item()
  ------------------------------------
  backlog_items array_t := array_t(
    'Es soll alles auf einmal können.',
      1,
      'yes',
      'Es soll die Investoren umhauen!',
      'extra large',
      --
    'Es soll beim rollen tönen.',
      2,
      'yes',
      'Beim Test im Büro.',
      'medium',
      --
    'Es soll zufällig leuchten.',
      2,
      'yes',
      'Im Dunkeln testen.',
      'small',
      --
    'Es kann fliegen.',
      2,
      'no',
      'Im Freien testen.',
      'large'
  );
  --
begin
  for i in 1..team_members.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    if i mod 2 = 1 then
      create_team_member(
        team_members(i),
        team_members(i+1)
      );
    end if;
  end loop;
  for i in 1..product_backlogs.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    if i mod 4 = 1 then
      create_product_backlog(
        product_backlogs(i),
        product_backlogs(i+1),
        product_backlogs(i+2),
        product_backlogs(i+3)
      );
    end if;
  end loop;
  for i in 1..backlog_items.count loop
    dbms_output.put_line('Executing SQL statement: #' || i);
    if i mod 5 = 1 then
      create_backlog_item(
        backlog_items(i),
        backlog_items(i+1),
        backlog_items(i+2),
        backlog_items(i+3),
        backlog_items(i+4)
      );
    end if;
  end loop;
  commit;
end;
