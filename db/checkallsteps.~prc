create or replace procedure checkallsteps(p_game_id   in number,
                                          p_player_id in number,
                                          p_map       in varchar2,
                                          p_error     out varchar2) is

  l_wrong_answer number;

begin

  select count(*) into l_wrong_answer
    from (select case
                    when s.killed = 2 then
                     1
                    else
                     s.killed
                  end as killed,
                 case
                    when p_map like
                         '%' || s.step || '%' then
                     1
                    else
                     0
                  end as s_map
            from steps s
           where s.game_id = p_game_id
             and s.player_id != p_player_id)
   where killed != s_map;

   if l_wrong_answer > 0 then 
     p_error := 'wrongmap';
   end if;  

end checkallsteps;
/
