create or replace procedure checkgamestate(p_game_id     in number,
                                           p_game_status out varchar2) is

  l_game_status      varchar2(255);
  l_game_player1_id  number;
  l_game_player2_id  number;
  l_winner_player_id number;
  l_count            number;

  g_ships_count constant number := 10;

  st_miss   constant number := 0;
  st_hit    constant number := 1;
  st_killed constant number := 2;
begin

  select g.status, g.player1_id, g.player2_id
    into l_game_status, l_game_player1_id, l_game_player2_id
    from games g
   where g.id = p_game_id;

  begin
  
    select x.player_id
      into l_winner_player_id
      from (select s.player_id, count(1) as count_killed
              from steps s
             where s.game_id = p_game_id
               and s.killed = st_killed
             group by s.player_id
            having count(1) = g_ships_count) x;
  
    update games g
       set g.status = 'finish', g.winner_id = l_winner_player_id
     where g.id = p_game_id;
  
    p_game_status := 'finish';
  
    commit;
  
  exception
    when no_data_found then
      begin
      
        select count(*)
          into l_count
          from steps s
         where s.game_id = p_game_id
         group by s.player_id
        having count(*) >= 100;
      
        if l_count >= 100 then
        
          update games g
             set g.status = 'finish'
           where g.id = p_game_id;
        
        end if;
      exception
        when no_data_found then
          null;
      end;
      null;
  end;

end checkgamestate;
/
