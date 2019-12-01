#!/usr/bin/env python

from sys import exit

import hy
#from gui import launch_gui
from gen import generate_stuff, train_network

if __name__ == '__main__':
    train_network("turku")
    generate_stuff("turku")
    exit(0)
