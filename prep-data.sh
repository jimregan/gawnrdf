#!/bin/sh
echo "Getting wordnet-gaeilge database"
wget https://raw.githubusercontent.com/kscanne/wordnet-gaeilge/master/en2wn.po
echo "Getting Wordnet 3.0 database"
wget http://wordnetcode.princeton.edu/3.0/WNdb-3.0.tar.gz
echo "...Extracting index.sense"
tar -zxvf WNdb-3.0.tar.gz dict/index.sense
rm WNdb-3.0.tar.gz

# https://github.com/martavillegas/EuroWordNetLemon/
echo "Getting MCR rdf data"
wget https://raw.githubusercontent.com/martavillegas/EuroWordNetLemon/master/eus-30-lmf.xml.ttl
wget https://raw.githubusercontent.com/martavillegas/EuroWordNetLemon/master/glg-30-lmf.v2.xml.ttl
wget https://raw.githubusercontent.com/martavillegas/EuroWordNetLemon/master/cat-30-lmf.xml.ttl
wget https://raw.githubusercontent.com/martavillegas/EuroWordNetLemon/master/spa-30-lmf.xml.ttl
