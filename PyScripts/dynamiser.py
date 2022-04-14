#!/usr/bin/env python3
import os
import sys
import glob
from apscheduler.schedulers.background import BackgroundScheduler

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

        self.sched = BackgroundScheduler()

    def run(self):
        """Docs
        """
        self.directory = sys.argv[2]

        frames = glob.glob(f'{self.directory}*')
        self.frames = sorted(frames,
                             key=lambda x: os.path.getmtime(
                                 os.path.join(self.directory, x))
                             )

        # TODO: Change between images & APSheduler support
        self.init_frame = str(sys.argv[3])
        self.delay = int(sys.argv[4])
        command = f'/usr/local/share/dynamic_themes/PyScripts/_switch_wallpaper.py {self.init_frame}'
        os.system(command)
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
