create or replace procedure getStatus(p_sessionId         in varchar2,
                                      p_status            out varchar2,
                                      p_recent_hit        out varchar2,
                                      p_recent_hit_result out varchar2,
                                      p_game_id           out number,
                                      p_winner            out varchar2,
                                      p_error             out varchar2) is

  l_player_id number;
  -- l_game_id                number;
  l_checksum_1             varchar2(36);
  l_checksum_2             varchar2(36);
  l_game_player1_id        number;
  l_game_player2_id        number;
  l_player_turn            number;
  l_start_date             date;
  l_count_another_new_game integer;
  l_winner_id              number;

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

  begin
    select g.id,
           g.status,
           g.check_sum_1,
           g.check_sum_2,
           g.player1_id,
           g.player2_id,
           g.player_turn,
           g.start_date
      into p_game_id,
           p_status,
           l_checksum_1,
           l_checksum_2,
           l_game_player1_id,
           l_game_player2_id,
           l_player_turn,
           l_start_date
      from games g
     where g.player1_id = l_player_id
        or g.player2_id = l_player_id
     order by g.id desc FETCH next 1 ROWS ONLY;
  
    if p_status = 'finish' then
      return;
    elsif p_status = 'gameover' then
      if (l_game_player1_id = l_player_id and
         l_winner_id = l_game_player1_id) or
         (l_game_player2_id = l_player_id and
         l_winner_id = l_game_player2_id) then
        p_winner := 'you';
      elsif l_winner_id = 0 then
        p_winner := 'nowinners';
      else
        p_winner := 'opponent';
      end if;
    
    end if;
  
  exception
    when no_data_found then
      p_status := 'nogame';
      return;
  end;

  select count(1)
    into l_count_another_new_game
    from Games g
   where g.start_date > l_start_date
     and (l_player_id = l_game_player1_id AND
         l_game_player2_id IN (g.player1_id, g.player2_id) or
         l_player_id = l_game_player2_id AND
         l_game_player1_id IN (g.player1_id, g.player2_id));

  if l_count_another_new_game > 0 then
    dbms_output.put_line('l_count_another_new_game:' ||
                         l_count_another_new_game);
    p_status := 'gameover';
    return;
  end if;

  if p_status = 'waitmap' then
    if l_player_id = l_game_player1_id and l_checksum_1 is not null then
      p_status := 'readyforgame';
    elsif l_player_id = l_game_player2_id and l_checksum_2 is not null then
      p_status := 'readyforgame';
    end if;
  
  end if;

  if p_status = 'waitturn' then
  
    if (l_player_id = l_game_player1_id and l_player_turn = 1) or
       (l_player_id = l_game_player2_id and l_player_turn = 2) then
      p_status := 'yourturn';
    else
      p_status := 'notyourturn';
    end if;
  
    if p_status = 'yourturn' then
      begin
        -- my recent hit
        select s.step, s.killed
          into p_recent_hit, p_recent_hit_result
          from steps s
         where s.game_id = p_game_id
           and s.player_id = l_player_id
         order by s.id desc FETCH next 1 ROWS ONLY;
      
      exception
        when no_data_found then
          null;
      end;
    
    end if;
  
  end if;

  if p_status = 'waitanswer' then
    -- recent hit from opponent
    if (l_player_id = l_game_player1_id and l_player_turn = 1) or
       (l_player_id = l_game_player2_id and l_player_turn = 2) then
      p_status := 'youranswer';
    
      select s.step
        into p_recent_hit
        from steps s
       where s.game_id = p_game_id
         and s.player_id != l_player_id
       order by s.id desc FETCH next 1 ROWS ONLY;
    
    else
      p_status := 'notyouranswer';
    end if;
  
  end if;

  commit;

end getStatus;
/
