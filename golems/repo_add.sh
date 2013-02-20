#!/bin/bash
#

mkdir precise
mkdir quantal

scp -r pushkar7@golems.org:~/dart.golems.org/downloads/linux/* ./

cd golems/
for deb in precise/*.deb
do
    reprepro -Vb . includedeb precise ../$deb 
done

for deb in quantal/*.deb
do
    reprepro -Vb . includedeb quantal ../$deb
done
