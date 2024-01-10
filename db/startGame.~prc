create or replace procedure startGame(p_sessionId in varchar2,
                                      p_game_id   out number,
                                      p_error     out varchar2) is

  l_player_id number;
  l_game_id   number;
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
    select x.id
      into l_game_id
      from (select g.id,
                   g.start_date,
                   case
                     when g.player2_id = l_player_id OR g.player2_id is null then
                      g.player1_id
                     else
                      g.player2_id
                   end as opponent_player_id
              from Games g
             where g.status IN ('wait', 'waitmap')
               and (l_player_id IN (g.player1_id, g.player2_id) or
                   g.player1_id != l_player_id and g.player2_id is null or
                   g.player2_id != l_player_id and g.player1_id is null)) x
     where not exists
     (select 1
              from Games g2
             where g2.start_date > x.start_date
               and x.opponent_player_id IN (g2.player1_id, g2.player2_id))
     order by x.id desc;
  
    update games g
       set g.player2_id = l_player_id
     where g.id = l_game_id
       and g.player1_id != l_player_id;
  
    update games g
       set g.player1_id = l_player_id
     where g.id = l_game_id
       and g.player2_id != l_player_id;
  
    update games g
       set g.status = 'waitmap'
     where g.id = l_game_id
       and g.player1_id is not null
       and g.player2_id is not null;
  
  exception
    when no_data_found then
    
      insert into games
        (id, player1_id, status, start_date)
      values
        (game_seq.nextval, l_player_id, 'wait', sysdate)
      returning id into l_game_id;
    
  end;
  commit;

  p_game_id := l_game_id;

end startGame;
/
