#!/bin/sh
# jagex pollutes ~/ with a few files (jagexcache, jagex_cl_oldschool_LIVE.dat, etc), so we'll move it to its own folder
exec /usr/lib/jvm/java-8-openjdk/jre/bin/java -Dhttps.protocols=TLSv1.2 -Duser.home="$HOME/.runescape" -jar /usr/share/runeliteplus/RuneLite.jar "$@"
