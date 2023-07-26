#!/usr/bin/env python3

# Copyright © 2023 Open Traffic Generator
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import sys
import argparse
import json
import snappi


def errlog(*args, **kwargs):
    """print message on STDERR"""
    print(*args, file=sys.stderr, **kwargs)


def error(*args, **kwargs):
    """log as error and exit"""
    errlog("Error:", *args, **kwargs)
    sys.exit(1)


def main():
    """
    Main function
    """
    # Parameters
    args = parse_args()

    api = snappi.api()
    cfg = api.config()
    if args.type == 'json':
        cfg.deserialize(json_from_file(args.file))
    else:
        error(f"{args.type} is not supported yet")

    print(cfg)


def parse_args():
    """
    Parse command line arguments
    """
    # Argument parser
    parser = argparse.ArgumentParser(description='Validate OTG configuration')

    # Add arguments to the parser
    parser.add_argument('-f', '--file',     required=True, help='file with OTG configuration')
    parser.add_argument('-t', '--type',     required=False, help='data type format: yaml | json',
                                            default='yaml',
                                            type=arg_type_check)
    # Parse the arguments
    return parser.parse_args()


def arg_type_check(s):
    """
    Check if the argument has a valid value
    """
    allowed_values = ['yaml', 'json']
    if s in allowed_values:
        return s
    raise argparse.ArgumentTypeError(f"type has to be one of {allowed_values}")


def json_from_file(file):
    """
    Read JSON from a file
    """
    try:
        with open(file, 'r', encoding='utf-8') as f:
            return json.load(f)
    except OSError as e:
        error("Can't read the file:", e)
    except json.decoder.JSONDecodeError as e:
        error("Can't parse the JSON file:", e)


if __name__ == '__main__':
    sys.exit(main())