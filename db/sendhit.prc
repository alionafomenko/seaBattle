create or replace procedure sendhit(p_sessionId in varchar2,
                                    p_hit       in varchar2,
                                    p_error     out varchar2) is
  l_player_id       number;
  l_game_id         number;
  l_game_status     varchar2(255);
  l_player_turn     number;
  l_game_player1_id number;
  l_game_player2_id number;

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

  if l_game_status = 'waitturn' then
  
    if (l_player_id = l_game_player1_id and l_player_turn = 1) or
       (l_player_id = l_game_player2_id and l_player_turn = 2) then
    
      begin
      
        insert into steps
          (id, game_id, player_id, step, step_date)
        values
          (step_seq.nextval, l_game_id, l_player_id, p_hit, Sysdate);
      
      exception
        when dup_val_on_index then
          p_error := 'alreadydidthathit';
      end;
    
      update games g
         set g.player_turn = 3 - g.player_turn, g.status = 'waitanswer'
       where g.id = l_game_id;
    
      commit;
    
    else
      p_error := 'notyourturn';
    end if;
    
  else
    p_error := 'notyourturn';
  end if;

end sendhit;
/
