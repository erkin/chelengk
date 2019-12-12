#!/usr/bin/env python

from sys import exit

import hy
from const import here
from gen import train_network, generate_song
from midi import make_and_save_midi

if __name__ == '__main__':
    train_network("turku")
    make_and_save_midi(generate_song("turku").notes, here("output/test.mid"))
    exit(0)
