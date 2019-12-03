#!/usr/bin/env python

from sys import exit

import hy
from const import here
from playback import save_tune
from gen import generate_song, train_network

if __name__ == '__main__':
    train_network("turku")
    for i in range(0, 30):
        save_tune(generate_song("turku").notes, here(f"output/sarki{i}.wav"))
    exit(0)
