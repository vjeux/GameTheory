# /bin/sh

# ./run.sh <# of the process to get stdout from> <processes ...>
# ./run.sh 0 bots/bot_coop.py bots/bot_coop.py bots/bot_coop.py

n=$1
shift

i=0
while [ -n "$1" ]; do
	i=$((i+1))
	if [ "$n" -eq "$i" ]; then
		sleep 1 && python "$1" &
	else
		sleep 1 && python "$1" > ${i}.log 2>&1 &
	fi
	shift
done

if [ "$n" -eq 0 ]; then
	coffee server/coffee/server.coffee
else
	sleep 1 && echo "Press Enter to Start a Game!" &
	coffee server/coffee/server.coffee > 0.log 2>&1
fi	

wait
