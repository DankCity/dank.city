script_id={{ req_id }}

while :; do sleep 10; curl -sI {{ ph_url }}ph/$script_id > /dev/null; done &
