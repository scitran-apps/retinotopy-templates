#! /usr/bin/env python2.7
# Parse config.json and return a string that can be passed to the calling function.
#
#

# Parse config file
def parse_config(args):
    import json
    import os

    # If the config file does not exist then use the default
    if not os.path.isfile(args.json_file):
        args.json_file = '/flywheel/v0/default_config.json';

    # Read the config json file
    with open(args.json_file, 'r') as jsonfile:
        config = json.load(jsonfile)

    if args.i:
        print config['config']['subject_id']

    # Print options for recon-all (TODO)
    if args.o:
        print ""

    # Convert surfaces to obj
    if args.s:
        if config['config']['convert_surfaces'] == 1:
            print config['config']['convert_surfaces']
        else:
            print ""

    # Convert mgz to nifti
    if args.n:
        if config['config']['convert_volumes'] == 1:
            print config['config']['convert_volumes']
        else:
            print ""

    # Convert aseg stats to csv
    if args.a:
        if config['config']['convert_aseg_stats'] == 1:
            print config['config']['convert_aseg_stats']
        else:
            print ""


if __name__ == '__main__':

    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--json_file', type=str, dest="json_file", default='/flywheel/v0/config.json', help='Full path to the input json config file.')
    ap.add_argument('-i', action='store_true', help='Return subject ID')
    ap.add_argument('-o', action='store_true', help='Return Recon-All Options')
    ap.add_argument('-s', action='store_true', help='Convert surfaces to obj')
    ap.add_argument('-n', action='store_true', help='Convert volume MGZ to NIfTI')
    ap.add_argument('-a', action='store_true', help='Convert ASEG stats to csv')
    args = ap.parse_args()

    parse_config(args)
