# nuclei

This scanner runs [nuclei](https://github.com/projectdiscovery/nuclei) tests against the targets.

Input expected: one base URL per line (including protocol) *PLUS* mandatory `-t` flag specifying at least one test to perform
Output provided: one json file per hostname/IP vulnerable to (one of) the test(s), with fields related to individual tests

There's a [ppbtemplates](ppbtemplates) folder to store custom tests which is bundled in the docker image and can be referenced under ppb, eg: `-t ppb/some_test.yaml`

## Run locally
- Customize `test/input/input.txt` and run `test/run.sh`
