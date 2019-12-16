#!/usr/bin/env python

from sys import exit
import hy
from gen import train_network, generate_song
from midi import make_and_save_midi

if __name__ == '__main__':
    train_network("sazsemaisi", 100, retrain=True)
    for i in range(1, 31):
        make_and_save_midi(generate_song("sazsemaisi").notes, f"output/{i}.mid")
    exit(0)
