#! /usr/bin/env python
# Parse the config json and return a string that can be passed to the calling function.


# Parse a config file
def parse_config(args):
    import json

    # Read the config json file
    with open(args.json_file, 'r') as jsonfile:
        config = json.load(jsonfile)

    if args.s:
        print config['config']['subject_id']

    # Print options for recon-all (TODO)
    if args.o:
        print ""


if __name__ == '__main__':

    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--json_file', type=str, dest="json_file", default='/flywheel/v0/config.json', help='Full path to the input json config file.')
    ap.add_argument('-s', action='store_true', help='Return subject ID')
    ap.add_argument('-o', action='store_true', help='Return Recon-All Options')
    args = ap.parse_args()

    parse_config(args)
