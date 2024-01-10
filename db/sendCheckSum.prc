create or replace procedure sendCheckSum(p_sessionId in varchar2,
                                         p_checksum  in varchar2,
                                         p_error     out varchar2) is

  l_player_id       number;
  l_game_player1_id number;
  l_game_player2_id number;
  l_game_id         number;
  l_player_turn     number;

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

  if p_checksum is not null then
  
    select g.player1_id, g.player2_id, g.id, g.player_turn
      into l_game_player1_id, l_game_player2_id, l_game_id, l_player_turn
      from games g
     where g.status = 'waitmap'
       and (g.player1_id = l_player_id or g.player2_id = l_player_id)
     order by g.id desc FETCH next 1 ROWS ONLY;
  
    if l_player_id = l_game_player1_id then
      update games g
         set g.check_sum_1 = p_checksum
       where g.id = l_game_id;
    elsif l_player_id = l_game_player2_id then
      update games g
         set g.check_sum_2 = p_checksum
       where g.id = l_game_id;
    end if;
  
    update games g
       set g.status = 'waitturn', g.player_turn = 1 + Dbms_Random.value
     where g.id = l_game_id
       and g.status = 'waitmap'
       and g.check_sum_1 is not null
       and g.check_sum_2 is not null;
  
    commit;
  
  else
    p_error := 'yourchecksumisnull';
  end if;

exception
  when no_data_found then
    p_error := 'nosuchgame';
  
end sendCheckSum;
/
