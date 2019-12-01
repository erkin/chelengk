#!/usr/bin/env python

from sys import exit

import hy
#from gui import launch_gui
from playback import play_tune
from gen import generate_song, train_network

if __name__ == '__main__':
    train_network("agirsemai")
    # play_tune(generate_song("agirsemai").notes)
    exit(0)
