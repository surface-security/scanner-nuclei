import argparse
from pathlib import Path
import subprocess
import re
import json
import sys

FILENAME_RE = re.compile(r'[^\w\d-]')


def parseargs():
    parser = argparse.ArgumentParser(description='nuclei wrapper')
    parser.add_argument(
        '-o', '--output',
        default='/output',
        type=Path,
        help='output directory for results'
    )
    parser.add_argument(
        '-c', '--concurrency',
        default=10,
        type=int,
        help='number of processes',
    )
    parser.add_argument(
        '-t', '--tests',
        action='append',
        help='tests to perform (as nuclei supports)',
    )
    parser.add_argument(
        '-d', '--debug',
        action='store_true',
        help='print nuclei output instead of suppressing it',
    )
    parser.add_argument(
        '-e', '--extra',
        action='append',
        help='extra args passed to nuclei',
    )

    parser.add_argument('inputfile', type=Path, help='THE input file')

    return parser.parse_args()


def main():
    args = parseargs()

    cmd = [
        'nuclei',
        '-c', str(args.concurrency),
        '-json',
        '-l', args.inputfile,
    ]
    if not args.debug:
        cmd.append('-silent')
    for t in args.tests or []:
        cmd.extend(['-t', t])
    cmd.extend(args.extra or [])

    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True)
    while True:
        o1 = proc.stdout.readline().strip()
        o2 = proc.poll()
        if o1 == '':
            if o2 is not None:
                # proc not running, break
                break
            # empty line...? skip parsing
            continue
        if args.debug:
            print(o1, file=sys.stderr)
        try:
            # must be json
            data = json.loads(o1)
            # and must have "host"
            print(f'[+] Found {data["host"]}')
        except Exception:
            print('error parsing', repr(o1))
            continue
        
        # FIXME: finish same format as baseline
        with (args.output / FILENAME_RE.sub('_', data['host'])).open('w') as f:
            json.dump(data, f)
    
    if o2:
        print(f'ERROR: nuclei exited with code {o2}')
        exit(o2)


if __name__ == "__main__":
    main()
