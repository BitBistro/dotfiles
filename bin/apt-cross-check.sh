#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# Build an associative set of installed packages in awk, then scan rdepends
apt-mark showauto | sort -u | while read -r pkg; do
  if apt-cache rdepends "$pkg" \
     | awk '
        BEGIN { RS="\n"; inlist=0 }
        NR==FNR { inst[$0]=1; next }
        /^Reverse Depends:/ { inlist=1; next }
        inlist {
          sub(/^[[:space:]]+/, "", $0)
          if ($0 != "" && inst[$0]) { found=1; exit }
        }
        END { exit(found ? 0 : 1) }
     ' <(dpkg-query -W -f='\n${binary:Package}') -; then
    :
  else
    echo "$pkg"
  fi
done
