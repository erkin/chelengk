#!/usr/bin/env python

from sys import exit

import hy
from gen import train_network

if __name__ == '__main__':
    train_network("turku")
    exit(0)
