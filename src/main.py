#!/usr/bin/env python

from sys import exit

import hy
from playback import play_tune
from songs import read_song_from_library

if __name__ == '__main__':
    play_tune(read_song_from_library('ussak--turku--sofyan--uzun_ince--asik_veysel.txt'))
    exit(0)
