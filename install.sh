#!/bin/bash

echo ">>Copying scripts to /usr/local/bin/"
find "${0%/*}" -type f -not -name "${0##*/}" -and \( -name "*.sh" -or -name "*.py" \) \
    | while read f; do
          echo "  $f"
          fn=${f##*/} && /bin/cp -a "$f" /usr/local/bin/ && \
              /bin/chmod 755 /usr/local/bin/$fn && \
              ( if echo "$fn" | grep -q '\.sh$'; then /bin/ln -sf "$fn" /usr/local/bin/${fn%.sh}; fi )
      done

ret=$(( PIPESTATUS + $? ))

echo ">>DONE."
exit $ret
