#!/bin/bash
#
#scp -r golems/* pushkar7@dart.golems.org:~/dart.golems.org/apt/
# use rsync
rsync -v -r -W golems/ pushkar7@golems.org:~/dart.golems.org/apt
