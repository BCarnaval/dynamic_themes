#!/usr/bin/env python3
import os
import sys

import _gen_daemon

# Colors used in terminal messages
RED, GREEN, ORANGE = '\033[31m', '\033[32m', '\033[33m',
CYAN, WHITE = '\033[36m', '\033[37m'


class Dynamiser(_gen_daemon.Daemon):
    def __init__(self, pidfile='/usr/local/share/_.pid',
                 stdin='/dev/null',
                 stdout='/dev/null',
                 stderr='/dev/null'):
        super().__init__(pidfile, stdin, stdout, stderr)

    def run(self):
        """Docs
        """
        command = f"/usr/local/share/dynamic_themes/set_themes.sh {directory} {bot_sched} {schedule} {shift}"
        os.system(command)
        self.worker.add_job(lambda: os.system(command),
                            trigger='interval', minutes=delay)
        self.worker.start()
        return

    def quit(self):
        """Docs
        """
        self.worker.shutdown()
        return


process = Dynamiser()

if 'start' == sys.argv[1]:
    _, __, directory, bot_sched, schedule, shift, delay = sys.argv
    process.start()
elif 'stop' == sys.argv[1]:
    process.stop()
elif 'restart' == sys.argv[1]:
    process.restart()
