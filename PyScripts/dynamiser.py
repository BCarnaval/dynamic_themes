#!/usr/bin/env python3
import os
import sys
import glob
from apscheduler.schedulers.background import BackgroundScheduler

import _gen_daemon
from _switch_wallpaper import switch_wall

# Colors used in terminal messages
RED, GREEN, ORANGE = '\033[31m', '\033[32m', '\033[33m',
CYAN, WHITE = '\033[36m', '\033[37m'


class Dynamiser(_gen_daemon.Daemon):
    def __init__(self, pidfile='_.pid', stdin='/dev/null', stdout='/dev/null',
                 stderr='/dev/null'):
        super().__init__(pidfile, stdin, stdout, stderr)

        self.sched = BackgroundScheduler()

    def run(self):
        """Docs
        """
        self.directory = sys.argv[2]

        frames = glob.glob(f'{sys.argv[2]}*')
        self.frames = sorted(frames,
                             key=lambda x: os.path.getmtime(
                                 os.path.join(sys.argv[2], x))
                             )

        self.init_frame = sys.argv[3]
        self.delay = sys.argv[4]

        switch_wall(self.init_frame)
        self.sched.add_job(lambda: switch_wall(self.init_frame),
                           'interval',
                           minutes=self.delay)
        self.sched.start()
        return

    def quit(self):
        """Docs
        """
        self.sched.shutdown()
        return


daemon = Dynamiser()

if 'start' == sys.argv[1]:
    daemon.start()
elif 'stop' == sys.argv[1]:
    daemon.stop()
elif 'restart' == sys.argv[1]:
    daemon.restart()
