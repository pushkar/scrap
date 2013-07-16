#!/bin/sh

ans="1"
sys=precise
boostv=1.46

process() 
{
  cd $1
  cmake .
  make
  cpack -G DEB
  sudo dpkg -i *.deb
  cp *.deb ../../
  cd ..
}

echo "Script to create the latest debians for dart, grip and grip-samples" 
echo "  1. System = precise, Boost Version = 1.46 (default)"
echo "  2. System = quantal, Boost Version = 1.49"
read -p "Select option [1/2]: " option
option=${option:-1}

if [ "$option" -eq 2 ] 
then
  sys=quantal
  boostv=1.49
else
  sys=precise
  boostv=1.46
fi

echo 'Generating debians for '$sys' with Boost version '$boostv''

# sudo apt-get install libboost$boostv-all-dev

mkdir tmp
cd tmp

git clone git://github.com/dartsim/dart.git
git clone git://github.com/dartsim/grip.git
git clone git://github.com/dartsim/grip-samples.git

sed -i 's/precise/'$sys'/g' dart/CMakeLists.txt 
sed -i 's/1.46/'$boostv'/g' dart/CMakeLists.txt 
sed -i 's/precise/'$sys'/g' grip/CMakeLists.txt 
sed -i 's/precise/'$sys'/g' grip-samples/CMakeLists.txt

process dart
process grip
process grip-samples

cd ..

scp *.deb pushkar7@golems.org:~/dart.golems.org/downloads/linux/$sys/
