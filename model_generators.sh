mix phx.gen.json Users User users --web Users name:string mail:string avatar:string provider:string uuid:uuid is_guest:boolean last_sign_in:utc_datetime
sleep 2
mix phx.gen.json Processing Task tasks --web Processing type:string params:map date_in:utc_datetime date_last_dispatch:utc_datetime date_out:utc_datetime attempts:integer flops:float processing_base_time:integer user_id:references:users
