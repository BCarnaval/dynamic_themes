#!/usr/bin/env python3
import os
import sys
from appscript import app, its, mactypes


def switch_wall(path):
    """Docs
    """
    f = path
    se = app('System Events')
    desktops = se.desktops.display_name.get()

    for d in desktops:
        desk = se.desktops[its.display_name == d]
        desk.picture.set(mactypes.File(f))

    command = f'/usr/local/share/dynamic_themes/_switch_iterm.sh {path}'
    os.system(command)
    return


if __name__ == "__main__":
    switch_wall(sys.argv[1])
