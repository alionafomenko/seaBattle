create or replace procedure getStatus(p_sessionId in varchar2,
                                      p_status    out varchar2,
                                      p_error     out varchar2) is

  l_player_id       number;
  l_checksum_1      varchar2(36);
  l_checksum_2      varchar2(36);
  l_game_player1_id number;
  l_game_player2_id number;

begin

  select s.player_id
    into l_player_id
    from sessions_for_players s
   where s.id = p_sessionId;

  select g.status, g.check_sum_1, g.check_sum_2, g.player1_id, g.player2_id
    into p_status,
         l_checksum_1,
         l_checksum_2,
         l_game_player1_id,
         l_game_player2_id
    from games g
   where g.player1_id = l_player_id
      or g.player2_id = l_player_id;

  if l_player_id = l_game_player1_id and l_checksum_1 is not null then
    p_status := 'readyforgame';
  elsif l_player_id = l_game_player2_id and l_checksum_2 is not null then
    p_status := 'readyforgame';
  end if;

exception
  when no_data_found then
    p_error := 'nosuchsession';
  
end getStatus;
