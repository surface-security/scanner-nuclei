#!/bin/sh

set -e

cd $(dirname $0)
cd ..

NAME=${1}

echo
echo '===> TEST CUSTOM TEMPLATE PATH'
echo

rm -fr test/output

docker run --rm \
           -v $(pwd)/test/input:/input:ro \
           -v $(pwd)/test/output:/output \
           ${NAME} \
           -t ppb/test_custom.yaml \
           /input/input.txt

echo
echo '## output file content ##'
echo
cat test/output/* | grep '"matched-at": "https://betfair.com/"' || (echo "FAILED"; exit 1)

echo
echo '===> TEST CORE TEMPLATE'
echo

rm -fr test/output

docker run --rm \
           -v $(pwd)/test/input:/input:ro \
           -v $(pwd)/test/output:/output \
           ${NAME} \
           -t exposed-panels/wordpress-login.yaml \
           /input/input.txt

echo
echo '## output file content ##'
echo
cat test/output/* | grep '"matched-at": "https://themeisle.com/wp-login.php"' || (echo "FAILED"; exit 1)
