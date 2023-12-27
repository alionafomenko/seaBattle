create or replace procedure sendCheckSum(p_sessionId in varchar2,
                                         p_checksum  in varchar2,
                                         p_error     out varchar2) is

  l_player_id       number;
  l_game_player1_id number;
  l_game_player2_id number;
  l_game_id         number;

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

  select g.player1_id, g.player2_id, g.id
    into l_game_player1_id, l_game_player2_id, l_game_id
    from games g
   where g.status = 'start'
     and (g.player1_id = l_player_id or g.player2_id = l_player_id)
   order by g.start_date desc FETCH next 1 ROWS ONLY;

  if l_player_id = l_game_player1_id then
    update games g
       set g.check_sum_1 = p_checksum
     where g.id = l_game_id;
  elsif l_player_id = l_game_player2_id then
    update games g
       set g.check_sum_2 = p_checksum
     where g.id = l_game_id;
  end if;

exception
  when no_data_found then
    p_error := 'nosuchgame';
  
end sendCheckSum;
