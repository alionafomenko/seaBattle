create or replace procedure sendAllShipsMap(p_sessionId in varchar2,
                                            p_map       in varchar2,
                                            p_error     out varchar2) is

  l_player_id       number;
  l_game_player1_id number;
  l_game_player2_id number;
  l_game_id         number;
  l_md5             varchar2(40);
  l_check_sum_1     varchar2(40);
  l_check_sum_2     varchar2(40);
  l_map_validation  varchar(5);
  l_map_valid_1     varchar2(40);
  l_map_valid_2     varchar2(40);

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

  if p_map is not null then
  
    select g.player1_id,
           g.player2_id,
           g.id,
           g.check_sum_1,
           g.check_sum_2,
           g.map_validation_1,
           g.map_validation_2
      into l_game_player1_id,
           l_game_player2_id,
           l_game_id,
           l_check_sum_1,
           l_check_sum_2,
           l_map_valid_1,
           l_map_valid_2
      from games g
     where g.status = 'finish'
       and (g.player1_id = l_player_id or g.player2_id = l_player_id)
     order by g.id desc FETCH next 1 ROWS ONLY;
  
    select standard_hash(p_map, 'MD5')
      into l_md5
      from dual;
  
    if l_player_id = l_game_player1_id then
    
      if l_md5 = l_check_sum_1 then
      
        checkallsteps(l_game_id, l_player_id, p_map, p_error);
      
      else
        p_error := 'wrongmap';
      end if;
    
      if p_error = 'wrongmap' then
        l_map_validation := 'no';
      else
        l_map_validation := 'yes';
      end if;
      
      l_map_valid_1 := l_map_validation;
    
      update games g
         set g.map_1 = p_map, g.map_validation_1 = l_map_validation
       where g.id = l_game_id;
    
    elsif l_player_id = l_game_player2_id then
    
      if l_md5 = l_check_sum_2 then
        checkallsteps(l_game_id, l_player_id, p_map, p_error);
      else
        p_error := 'wrongmap';
      end if;
    
      if p_error = 'wrongmap' then
        l_map_validation := 'no';
      else
        l_map_validation := 'yes';
      end if;
      
      l_map_valid_2 := l_map_validation;
    
      update games g
         set g.map_2 = p_map, g.map_validation_2 = l_map_validation
       where g.id = l_game_id;
    
    end if;
  
    commit;
  
    update games g
       set g.status = 'gameover'
     where g.id = l_game_id
       and g.status = 'finish'
       and g.map_1 is not null
       and g.map_2 is not null;
       
       
  
    if l_map_valid_1 = 'yes' and l_map_valid_2 = 'no' then
      update games g
         set g.winner_id = g.player1_id
       where g.id = l_game_id;
    elsif l_map_valid_2 = 'yes' and l_map_valid_1 = 'no' then
      update games g
         set g.winner_id = g.player2_id
       where g.id = l_game_id;
       
    elsif l_map_valid_1 = 'no' and l_map_valid_2 = 'no' then
      update games g
         set g.winner_id = 0
       where g.id = l_game_id;
    end if;
  
    commit;
  
  else
    p_error := 'yourmapisnull';
  end if;

exception
  when no_data_found then
    p_error := 'nosuchgame';
  
end sendAllShipsMap;
/
