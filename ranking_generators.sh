mix phx.gen.json Ranking Season seasons --web Ranking start_date:utc_datetime end_date:utc_datetime name:string
sleep 2
mix phx.gen.json Ranking CurrentSeasonRanking current_season_ranking --web Ranking user_id:references:users processing_ranking:integer elapsed_time_ranking:integer seasons:references:seasons
