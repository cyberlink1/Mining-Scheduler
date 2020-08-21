#!/bin/bash
apt-get install unzip
wget -c https://github.com/ethereum-mining/ethminer/releases/download/v0.19.0-alpha.0/ethminer-0.19.0-alpha.0-cuda-9-linux-x86_64.tar.gz -O - | tar -zx --strip-components=1 --one-top-level=ethminer-0.19
wget -c https://github.com/todxx/teamredminer/releases/download/0.7.9/teamredminer-v0.7.9-linux.tgz -O - | tar -zx --strip-components=1 --one-top-level=teamredminer-0.7.9
wget -c https://github.com/Lolliedieb/lolMiner-releases/releases/download/1.06/lolMiner_v1.06_Lin64.tar.gz -O - | tar -zx --strip-components=1 --one-top-level=lolminer-1.06
wget -c https://github.com/xmrig/xmrig/releases/download/v6.3.2/xmrig-6.3.2-xenial-x64.tar.gz -O - | tar -zx --strip-components=1 --one-top-level=xmrig-6.3.2
wget -c https://github.com/Claymore-Dual/Claymore-Dual-Miner/releases/download/15.0/Claymore.s.Dual.Ethereum.AMD+NVIDIA.GPU.Miner.v15.0.-.LINUX.zip -O temp.zip
unzip -j -d Claymore-15.0 temp.zip
chmod 755 Claymore-15.0/ethdcrminer64
rm temp.zip
