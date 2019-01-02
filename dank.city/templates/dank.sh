while :; do sleep 10; curl -sI {{ url_for('phone_home', req_id=req_id, _external=True) }} > /dev/null; done &
