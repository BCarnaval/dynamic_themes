#!/usr/bin/env python3
import sys
import time

import _gen_daemon

# Colors used in terminal messages
RED, GREEN, ORANGE = '\033[31m', '\033[32m', '\033[33m',
CYAN, WHITE = '\033[36m', '\033[37m'


class Dynamiser(_gen_daemon.Daemon):
    def run(self):
        self.i = 0
        with open('test1.txt', 'w') as f:
            f.write(str(self.i))
        while True:
            self.i += 1
            time.sleep(1)

    def quit(self):
        with open('test2.txt', 'w') as f:
            f.write(str(self.i))


daemon = Dynamiser()

if 'start' == sys.argv[1]:
    daemon.start()
elif 'stop' == sys.argv[1]:
    daemon.stop()
elif 'restart' == sys.argv[1]:
    daemon.restart()
