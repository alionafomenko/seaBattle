create or replace procedure registration(p_name     in varchar2,
                                         p_password in varchar2,
                                         p_error    out varchar2) is
begin

  insert into players
  values
    (player_seq.nextval, p_name, p_password);

  p_error := '';

  commit;

exception
  when dup_val_on_index then
  
    p_error := 'hasalredysuchname';
  
end;
