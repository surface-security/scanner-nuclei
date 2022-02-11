#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 [TEMPLATE_PATH] [other [nuclei [args]]]"
    exit 2
fi

set -e

TEMPL="$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
shift

cd $(dirname $0)

docker build -t temp_nuclei .

docker run --rm --entrypoint=/nuclei -v "$TEMPL":"$TEMPL":ro temp_nuclei -t "$TEMPL" "$@"
