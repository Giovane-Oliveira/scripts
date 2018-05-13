#!/bin/bash

echo "Limpando pacotes quebrados..."
sleep 5

rm -rf /var/lib/dpkg/info/a.*

rm -rf /var/lib/dpkg/info/*.* 

rm /var/cache/apt/archives/*.deb

echo "Quase Pronto..."
sleep 5

rm /var/lib/apt/lists/* -vf


echo "Limpando e atualizando repositório..."
sleep 3

apt-get autoremove
apt-get clean
apt-get install -f
apt-get update


echo "Pronto!"

