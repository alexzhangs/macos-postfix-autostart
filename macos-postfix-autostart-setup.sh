#!/bin/bash

set -o pipefail -e

# Debug
if [[ $DEBUG -gt 0 ]]; then
    set -x
else
    set +x
fi

change_plist () {
    local file=${1:?}
    local config="
	<key>RunAtLoad</key>
	<true/>
"
    local mark_begin="<!-- BEGIN: Run after user logged on -->"
    local mark_end="<!-- END: Run after user logged on -->"
    
    inject -c "$config" -f "$file" \
           -p before \
           -b "^<\/dict>$" \
           -m "$mark_begin" \
           -n "$mark_end" \
           -x "$mark_begin" \
           -y "$mark_end"

    #sed -i '' 's|<string>org.postfix.master</string>|<string>local.org.postfix.master</string>|' "$file"
}

src_file="/System/Library/LaunchDaemons/org.postfix.master.plist"
dest_file="/Library/LaunchDaemons/local.org.postfix.master.plist"

if [[ -f $src_file ]]; then
    if [[ -f $dest_file ]]; then
        printf "Destination file already exists, will be overrided.\n"
    fi

    printf "Copying file to: $dest_file\n"
    /bin/cp -a "$src_file" "$dest_file"
    change_plist "$dest_file"
    launchctl unload -w "$src_file"
    launchctl load -w "$dest_file"
    printf "Done\n"
else
    printf "Not found the plist file: %s\n" "$src_file" >&2
    exit 255
fi

exit
