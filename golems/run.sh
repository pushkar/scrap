#!/bin/sh

sys=${1}
boostv=${2}

usage()
{
    echo "usage: ./run.sh [<precise/quantal> <boostv>]" 
    echo "Example: ./run.sh precise 1.46"
    echo ""
    exit 1
}

[ "$#" -lt 2 ] && usage

echo 'Building for '$sys' with Boost version '$boostv

sudo apt-get install libboost$boostv-all-dev

mkdir repo
cd repo
git clone git://github.com/golems/libccd.git
git clone git://github.com/golems/fcl.git
git clone git://github.com/golems/dart.git
git clone git://github.com/golems/grip.git
git clone git://github.com/golems/grip-samples.git

sed -i 's/precise/'$sys'/g' ~/repo/libccd/CMakeLists.txt 
sed -i 's/precise/'$sys'/g' ~/repo/fcl/CMakeLists.txt 
sed -i 's/1.46/'$boostv'/g' ~/repo/fcl/CMakeLists.txt 
sed -i 's/precise/'$sys'/g' ~/repo/dart/CMakeLists.txt 
sed -i 's/1.46/'$boostv'/g' ~/repo/dart/CMakeLists.txt 
sed -i 's/precise/'$sys'/g' ~/repo/grip/CMakeLists.txt 

cd ~/repo/libccd
cmake .
make
cpack -G DEB
sudo dpkg -i *.deb
cp *.deb ~/

cd ~/repo/fcl
git pull origin
git checkout debian_gen
cmake .
make
cpack -G DEB
sudo dpkg -i *.deb
cp *.deb ~/

cd ~/repo/dart
cmake .
make
cpack -G DEB
sudo dpkg -i *.deb
cp *.deb ~/

cd ~/repo/grip
cmake .
make
cpack -G DEB
sudo dpkg -i *.deb
cp *.deb ~/

cd ~/repo/grip-samples
cmake .
make
cpack -G DEB
sudo dpkg -i *.deb
cp *.deb ~/

cd ~
scp *.deb pushkar7@golems.org:~/dart.golems.org/downloads/linux/$sys/
