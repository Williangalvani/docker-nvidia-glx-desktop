#!/bin/bash -e

# this forcefully removes files and packages that are not needed
# this WILL leave the system in a supposedly broken state
# still it makes the image smaller and still works for our purposes



dpkg -P --force-depends libgl1-mesa-dri
dpkg -P --force-depends libflite1
dpkg -P --force-depends humanity-icon-theme
dpkg -P --force-depends libmfx1
dpkg -P --force-depends libpython3.10-dev
dpkg -P --force-depends iso-codes
dpkg -P --force-depends libx265-199
dpkg -P --force-depends libllvm15
dpkg -P --force-depends cpp-11