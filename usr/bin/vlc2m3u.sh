#!/bin/sh
#
# get playlist file from weburg, convert it from xml to m3u

# where to get the original file
URL=http://weburg.tv/playlist.vlc

# where to put the converted playlist
DEST=/opt/share/xupnpd/playlists/weburgtv.m3u

# temporary file
TMP=/var/tmp/newplaylist.vlc

PATH='/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'

# get the file and check it is not empty
rm -f ${TMP}
wget -q -O ${TMP} ${URL}
if test ! -s ${TMP} ; then 
  echo "Error downloading ${URL}" 
  exit 1 
fi

# start processing the file
sed 's|</track>|\n|g' <${TMP} > ${TMP}.1
awk -F '<' -f - ${TMP}.1 >${TMP}.2 <<\AWK
BEGIN { 
  print "#EXTM3U name=\"Weburg TV\"" 
  ORS = ""
}
/track>/ {
  location = ""; title = ""; image = "";
  for (i = 1; i <= NF; i++) {
    if( $i ~ /^location>/ ) {
      location = $i
      sub(/^[^>]+>/, "", location)
      sub(/<.*$/, "", location)
    }   
    if( $i ~ /^title>/ ) {
      title = $i
      sub(/^[^>]+>/, "", title)
      sub(/<.*$/, "", title)
    }   
    if( $i ~ /^image>/ ) {
      image = $i
      sub(/^[^>]+>/, "", image)
      sub(/<.*$/, "", image)
    }   
  }
  print "#EXTINF:0"
  if( image ~ /./ )
    print " logo=" image
  print "," title "\n" location "\n"
}
AWK

# all is ready.  Moving results to destination, cleaning up
mv ${TMP}.2 ${DEST}
rm -f ${TMP} ${TMP}.1 ${TMP}.2
