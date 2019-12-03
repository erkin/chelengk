#!/usr/bin/env python

from sys import exit

import hy
from gui import launch_gui
from const import here
from playback import save_tune
from gen import generate_song, train_network

if __name__ == '__main__':
    for i in range(0, 30):
        save_tune(generate_song("turku", epochs=20).notes, here(f"output/turku{i}.wav"))
    # launch_gui()
    exit(0)
