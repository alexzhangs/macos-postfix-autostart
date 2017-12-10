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

    #sed -i '' "s|<string>$service_name</string>|<string>local.$service_name</string>|" "$file"
}

get_postfix_service_name () {
    if launchctl list org.postfix.master >/dev/null 2>&1; then
        echo org.postfix.master
    elif launchctl list com.apple.postfix.master >/dev/null 2>&1; then
        echo com.apple.postfix.master
    else
        return 255
    fi
}

service_name=$(get_postfix_service_name)
if [[ -z $service_name ]]; then
    echo "Failed to get postfix service name"
    exit 255
fi

src_file="/System/Library/LaunchDaemons/$service_name.plist"
dest_file="/Library/LaunchDaemons/local.$service_name.plist"

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
