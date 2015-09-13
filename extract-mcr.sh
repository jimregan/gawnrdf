# the MCR repo omits the English data, so we try to extract as many links
# as we can.
rapper -i turtle -o ntriples eus-30-lmf.xml.ttl |grep '^<http://lodserver.iula.upf.edu/id/WordNetLemon/EU/eus-30-'|sed -e 's#/EU/eus#/ILI/ili#g' >> /tmp/mcrrdf.nt
rapper -i turtle -o ntriples cat-30-lmf.xml.ttl |grep '^<http://lodserver.iula.upf.edu/id/WordNetLemon/CAT/cat-30-'|sed -e 's#/CAT/cat#/ILI/ili#g' >> /tmp/mcrrdf.nt
rapper -i turtle -o ntriples spa-30-lmf.xml.ttl |grep '^<http://lodserver.iula.upf.edu/id/WordNetLemon/ES/spa-30-'|sed -e 's#/ES/spa#/ILI/ili#g' >> /tmp/mcrrdf.nt
rapper -i turtle -o ntriples glg-30-lmf.v2.xml.ttl |grep '^<http://lodserver.iula.upf.edu/id/WordNetLemon/GL/glg-30-'|sed -e 's#/GL/glg#/ILI/ili#g' >> /tmp/mcrrdf.nt
sort /tmp/mcrrdf.nt | uniq > /tmp/mcruniq.nt
rm /tmp/mcrrdf.nt
# 
rapper -i turtle -o ntriples gawn-lemon.ttl  |grep 'nearlySameAs> <http://lodserver.iula.upf.edu/id/WordNetLemon/EN/eng' > /tmp/mcr-links.nt
