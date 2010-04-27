#!/bin/sh

RUBY="/usr/bin/ruby"
ABSPATH="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"
ROOT=$(dirname "$ABSPATH")
SERVER="${ROOT}/server"
SERVER_PID="${ROOT}/log/rrdpd.pid"
SERVER_LOG="${ROOT}/log/rrdpd.log"

mkdir -p "${ROOT}/log"

case "$1" in
    run)
        cd $ROOT
        exec ${RUBY} ${SERVER} >> ${SERVER_LOG} 2>&1
    ;;

    start)
        echo -n "Starting server: "
        cd $ROOT
        exec nohup ${RUBY} ${SERVER} >> ${SERVER_LOG} 2>&1 &
        echo $! > ${SERVER_PID}
        echo "Ok"
    ;;

    stop)
        echo -n "Stopping server: "
        kill `cat ${SERVER_PID}` &> /dev/null
        rm -f ${SERVER_PID}
        echo "Ok"
    ;;

    stopkill)
        echo -n "Killing server: "
        kill -9 $(cat ${SERVER_PID}) &> /dev/null
        for i in `seq 1 2`;
        do
          if [ "$(ps ax | grep $(cat ${SERVER_PID}) | grep -v grep)" == "" ]; then
            sleep 5
          else
            killed=1
            break
          fi
        done
        if [ "$killed" -eq 0 ]; then
          kill -9 $(cat ${SERVER_PID}) &> /dev/null
        fi
        rm -f ${SERVER_PID}
        echo "Ok"
    ;;

    restart)
        $0 stop
        sleep 1
        $0 start
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|stopkill}"
        exit 1
    ;;
esac

exit 0
