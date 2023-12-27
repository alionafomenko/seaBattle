create or replace procedure startGame(p_sessionId in number,
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
    select g.id
      into l_game_id
      from games g
     where g.player1_id = l_player_id
       and g.player2_id is null;
  
  exception
    when no_data_found then
    
      begin
        select g.id
          into l_game_id
          from Games g
         where g.player1_id != l_player_id
           and g.player2_id is null;
      
        update games g
           set g.player2_id = l_player_id, g.status = 'start'
         where g.id = l_game_id;
      
      exception
        when no_data_found then
        
          insert into games
            (id, player1_id, status, start_date)
          values
            (game_seq.nextval, l_player_id, 'wait', sysdate);
        
      end;
      commit;
  end;

end startGame;
