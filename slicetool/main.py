import argparse
import os
import sys

def main(args=None):
    parser = argparse.ArgumentParser(prog='slicetool', description='Command line interface to slice STL files.')
    parser.add_argument('-i', '--input', action='store', type=str, required=True)
    parser.add_argument('-o', '--output', action='store', type=str)
    args = parser.parse_args()

    input_arg = args.input
    input_path = os.path.expanduser(input_arg)
    if not os.path.isdir(input_path):
        print('The path specified does not exist')
        sys.exit()

    output_arg = args.output
    output_path = os.getcwd()
    if output_arg: 
        output_path = os.path.expanduser(output_arg)
        
    print("Input: " + input_path)
    print("Output: " + output_path)
