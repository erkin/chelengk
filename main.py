#!/usr/bin/env python

from sys import exit

import hy
# from gui import launch_gui
from const import here
from playback import save_tune
from gen import generate_song, train_network

if __name__ == '__main__':
    # train_network("sarki")
    # play_tune(generate_song("agirsemai").notes)
    save_tune(generate_song("agirsemai").notes, here("output/agirsemai.wav"))
    save_tune(generate_song("turku").notes, here("output/turku.wav"))
    # launch_gui()
    exit(0)
