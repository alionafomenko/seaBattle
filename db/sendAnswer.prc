create or replace procedure sendAnswer(p_sessionId  in varchar2,
                                       p_hit_result in number,
                                       p_error      out varchar2) is
  l_player_id       number;
  l_game_id         number;
  l_game_status     varchar2(255);
  l_player_turn     number;
  l_game_player1_id number;
  l_game_player2_id number;
  l_step_id         number;

  st_miss constant number := 0;
begin

  begin
    select s.player_id
      into l_player_id
      from sessions_for_players s
     where s.id = p_sessionId;
  exception
    when no_data_found then
      p_error := 'nosuchsession';
      return;
  end;

  select g.id, g.status, g.player_turn, g.player1_id, g.player2_id
    into l_game_id,
         l_game_status,
         l_player_turn,
         l_game_player1_id,
         l_game_player2_id
    from games g
   where g.player1_id = l_player_id
      or g.player2_id = l_player_id
   order by g.start_date desc FETCH next 1 ROWS ONLY;

  if l_game_status = 'waitanswer' then
  
    if (l_player_id = l_game_player1_id and l_player_turn = 1) or
       (l_player_id = l_game_player2_id and l_player_turn = 2) then
    
      select s.id
        into l_step_id
        from steps s
       where s.game_id = l_game_id
         and s.player_id != l_player_id
       order by s.id desc FETCH next 1 ROWS ONLY;
    
      update steps s set s.killed = p_hit_result where s.id = l_step_id;
    
      update games g
         set g.player_turn = case
                               when p_hit_result = st_miss then
                                g.player_turn
                               else
                                3 - g.player_turn -- reverse turn
                             end,
             g.status      = 'waitturn'
       where g.id = l_game_id;
    
      checkgamestate(l_game_id, l_game_status);
    
      commit;
    
    else
      p_error := 'notyouranswer';
    end if;
  
  else
    p_error := 'error';
  end if;

end sendAnswer;
/
