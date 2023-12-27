create or replace procedure autorisation(p_sessionId IN varchar2,
                                         p_name      in varchar2,
                                         p_password  in varchar2,
                                         p_error     out varchar2) is

  l_player_id       number;
  l_player_password varchar2(255);
begin

  select p.id, p.password
    into l_player_id, l_player_password
    from Players p
   where p.name = p_name;

  if l_player_password = p_password then
    begin
      insert into sessions_for_players
      values
        (p_sessionId, l_player_id);
    exception
      when dup_val_on_index then
        update sessions_for_players s
           set s.player_id = l_player_id
         where s.id = p_sessionId;
    end;
    commit;
    return;
  else
    p_error := 'invalidpassword';
  end if;

exception
  when no_data_found then
    p_error := 'nouser';
  
end autorisation;
