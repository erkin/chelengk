#!/usr/bin/env python

from sys import exit

import hy
from const import here
from gen import train_network, generate_song
from midi import make_and_save_midi
from songs import Note

if __name__ == '__main__':
    # train_network("zeybek", 10)
    make_and_save_midi(map(lambda x: Note(x[0], x[1], x[2]), h), "output/h.mid")
    # make_and_save_midi(generate_song("ilahi").notes, "output/h.mid")
    exit(0)
