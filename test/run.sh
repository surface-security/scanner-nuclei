#!/bin/sh

set -e

cd $(dirname $0)
cd ..

./build.sh nopush

if [ -e '.git' ]; then
    NAME=$(basename $(cat .git/config| grep '/scanners/' | tr -d ' ') | sed -e 's/\.git$//g')
else
    # fingers crossed name is the same as repo
    NAME=$(basename $(pwd))
fi

echo
echo '===> TEST CUSTOM TEMPLATE PATH'
echo

rm -fr test/output

docker run --rm \
           -v $(pwd)/test/input:/input:ro \
           -v $(pwd)/test/output:/output \
           test/${NAME}:dev \
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
           test/${NAME}:dev \
           -t exposed-panels/wordpress-login.yaml \
           /input/input.txt

echo
echo '## output file content ##'
echo
cat test/output/* | grep '"matched-at": "https://themeisle.com/wp-login.php"' || (echo "FAILED"; exit 1)
