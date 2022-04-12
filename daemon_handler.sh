#!/usr/bin/env bash
#
# eg_daemon      Startup script for eg_daemon
#
# chkconfig: - 87 12
# description: eg_daemon is a dummy Python-based daemon
# config: /etc/eg_daemon/eg_daemon.conf
# config: /etc/sysconfig/eg_daemon
# pidfile: /var/run/eg_daemon.pid
#
### BEGIN INIT INFO
# Provides: eg_daemon
# Required-Start: $local_fs
# Required-Stop: $local_fs
# Short-Description: start and stop eg_daemon server
# Description: eg_daemon is a dummy Python-based daemon
### END INIT INFO

# # Source function library.
# . /etc/rc.d/init.d/functions

# if [ -f /etc/sysconfig/eg_daemon ]; then
#         . /etc/sysconfig/eg_daemon
# fi

eg_daemon=/Users/antoinedelagrave/dynamic_themes/daemon
prog=${eg_daemon}/_global_scheduler.py
pidfile=${eg_daemon}/run/eg_daemon.pid
logfile=${eg_daemon}/log/eg_daemon.log
RETVAL=0

OPTIONS=""

start() {
        echo -n $"Starting $prog: "

        if [[ -f ${pidfile} ]] ; then
            pid=$( cat $pidfile )
            isrunning=$( ps -elf | grep  $pid | grep $prog | grep -v grep )

            if [[ -n ${isrunning} ]] ; then
                echo $"$prog already running"
                return 0
            fi
        fi
        ${prog} -p ${pidfile} -l ${logfile} ${OPTIONS}
        return ${RETVAL}
}

stop() {
    if [[ -f ${pidfile} ]] ; then
        pid=$( cat $pidfile )
        isrunning=$( ps -elf | grep $pid | grep $prog | grep -v grep | awk '{print $4}' )

        if [[ ${isrunning} -eq ${pid} ]] ; then
            echo -n $"Stopping $prog: "
            kill $pid
        else
            echo -n $"Stopping $prog: "
        fi
        RETVAL=$?
    fi
    return $RETVAL
}

reload() {
    echo -n $"Reloading $prog: "
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status -p $pidfile $prog
    RETVAL=$?
    ;;
  restart)
    stop
    start
    ;;
  force-reload|reload)
    reload
    ;;
  *)
    echo $"Usage: $prog {start|stop|restart|force-reload|reload|status}"
    RETVAL=2
esac

exit $RETVAL
