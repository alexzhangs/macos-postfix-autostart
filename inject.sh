#!/bin/bash

# Clean on any exit
trap 'clean_exit $?' 0 SIGHUP SIGINT SIGTERM

# Exit on any error
set -o pipefail -e

# Debug
[[ $DEBUG -gt 0 ]] && set -x || set +x


clean_exit () {
    if [[ -n ${CLEANERS[@]} ]]; then
        eval "${CLEANERS[@]}"
    fi
    return $1
}

array_append () {
    local arr_name=${1:?}
    shift
    while [[ $# -gt 0 ]]; do
        eval $arr_name[\${#$arr_name[@]}]=\$1
        shift
    done
}

is_mac () {
    uname | grep -iq 'darwin'
}

sed_regx () {
    is_mac && sed -E "$@" || sed -r "$@"
}

sed_inplace () {
    is_mac && sed -i '' "$@" || sed -i "$@"
}

sed_regx_inplace () {
    is_mac && sed -E -i '' "$@" || sed -r -i "$@"
}

usage () {
    printf "Inject content into file.\n"
    printf "${0##*/}\n"
    printf "\t-c CONTENT\n"
    printf "\t-f FILE\n"
    printf "\t-p <begin|end|after|before>\n"
    printf "\t[-a REGEX]\n"
    printf "\t[-b REGEX]\n"
    printf "\t[-m MARK_BEGIN]\n"
    printf "\t[-n MARK_END]\n"
    printf "\t[-x REGEX_MARK_BEGIN]\n"
    printf "\t[-y REGEX_MARK_END]\n"
    printf "\t[-h]\n"

    printf "OPTIONS\n"
    printf "\t-c CONTENT\n\n"
    printf "\tContent to inject.\n\n"

    printf "\t-f FILE\n\n"
    printf "\tFile to inject to.\n\n"

    printf "\t-p <begin|end|after|before>\n\n"
    printf "\tWhere to inject in the FILE.\n\n"

    printf "\t[-a REGEX]\n\n"
    printf "\tUse together with '-p after'.\n\n"

    printf "\t[-b REGEX]\n\n"
    printf "\tUse together with '-p before'.\n\n"

    printf "\t[-m MARK_BEGIN]\n\n"
    printf "\tUse together with -n.\n"
    printf "\tWith begin and end mark, injection can be run repeatly and safety.\n\n"

    printf "\t[-n MARK_END]\n\n"
    printf "\tUse together with -m.\n"
    printf "\tWith begin and end mark, injection can be run repeatly and safety.\n\n"

    printf "\t[-x REGEX_MARK_BEGIN]\n\n"
    printf "\tUse together with -y.\n"
    printf "\tWith begin and end mark, injection can be run repeatly and safety.\n\n"

    printf "\t[-y REGEX_MARK_END]\n\n"
    printf "\tUse together with -x.\n"
    printf "\tWith begin and end mark, injection can be run repeatly and safety.\n\n"

    printf "\t[-h]\n\n"
    printf "\tThis help.\n\n"
    exit 255
}

while getopts c:f:p:a:b:m:n:x:y:h opt; do
    case $opt in
        c)
            content=$OPTARG
            ;;
        f)
            file=$OPTARG
            ;;
        p)
            # begin, end, after, before
            position=$OPTARG
            ;;
        a)
            regex_after=$OPTARG
            ;;
        b)
            regex_before=$OPTARG
            ;;
        m)
            mark_begin=$OPTARG
            ;;
        n)
            mark_end=$OPTARG
            ;;
        x)
            regex_mark_begin=$OPTARG
            ;;
        y)
            regex_mark_end=$OPTARG
            ;;
        h|*)
            usage
            ;;
    esac
done

# Backup
bak_file="${file:?}-$(date '+%Y%m%d%H%M%S')"
/bin/cp -a "${file:?}" "${bak_file:?}"

# Temporary file
tmp_file=/tmp/${0##*/}-${file##*/}-$$
tmp_inj_file=/tmp/${0##*/}-$$
/bin/cp -a "${file:?}" "${tmp_file:?}"

array_append CLEANS "rm -f ${tmp_file:?};"

if [[ -n $mark_begin && -n $mark_end ]]; then
    cat > "${tmp_inj_file:?}" << EOF
${mark_begin:?}
${content:?}
${mark_end:?}
EOF
else
    cat > "${tmp_inj_file:?}" << EOF
${content:?}
EOF
fi

array_append CLEANS "rm -f ${tmp_inj_file:?};"

# Remove early injection if exists
if [[ -n $regex_mark_begin && -n $regex_mark_end ]]; then
    sed_regx_inplace "/${regex_mark_begin:?}/,/${regex_mark_end:?}/d" "${tmp_file:?}"
fi

# Injecting
case ${position:?} in
    begin)
        sed_inplace "1{
h
r ${tmp_inj_file:?}
g
N
}" "${tmp_file:?}"
        ;;
    end)
        sed_inplace "$ r ${tmp_inj_file:?}" "${tmp_file:?}"
        ;;
    after)
        sed_regx_inplace "/${regex_after:?}/ r ${tmp_inj_file:?}" "${tmp_file:?}"
        ;;
    before)
        sed_regx_inplace "/${regex_before:?}/{
h
r ${tmp_inj_file:?}
g
N
}" "${tmp_file:?}"
        ;;
    *)
        exit 255
        ;;
esac

cp -a "${tmp_file:?}" "${file:?}"

exit
