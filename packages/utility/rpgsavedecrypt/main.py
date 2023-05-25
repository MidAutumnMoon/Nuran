#!@interpreter@

# Based on https://github.com/uttarayan21/rpgsavedecrypt

import lzstring

import json
import argparse
import os
import errno
import sys


def decode_rpgsave( content ):
    lz = lzstring.LZString()
    decoded = lz.decompressFromBase64( content )
    return json.dumps(
        json.loads( decoded ),
        indent=4,
    )


def encode_rpgsave( content ):
    lz = lzstring.LZString()
    return lz.compressToBase64( content )


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-e",
        "--encode",
        help="Encode the decoded savefile",
        action="store_true"
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Specify the output file instead of printing to stdout"
    )
    parser.add_argument(
        "file",
        help="The rpgsave file which is either encoded / decoded"
    )

    if len( sys.argv ) == 1:
        parser.print_help( sys.stderr )
        sys.exit( 0 )

    args = parser.parse_args()

    if os.path.isfile( args.file ):
        savefile = open(args.file, "r")
    else:
        parser.print_usage()
        raise FileNotFoundError(
            errno.ENOENT,
            os.strerror( errno.ENOENT ),
            args.file
        )
        sys.exit(1)

    if args.encode == True:
        output = encode_rpgsave( savefile.read() )
    else:
        output = decode_rpgsave( savefile.read() )

    if args.output:
        with open( args.output, "w" ) as destfile:
            destfile.write( output )
    else:
        print( output )
