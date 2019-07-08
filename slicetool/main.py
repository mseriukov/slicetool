import argparse
import os
import sys
import numpy
from stl import mesh
from mpl_toolkits import mplot3d
from matplotlib import pyplot

def main(args=None):
    parser = argparse.ArgumentParser(prog='slicetool', description='Command line interface to slice STL files.')
    parser.add_argument('-i', '--input', action='store', type=str, required=True)
    parser.add_argument('-o', '--output', action='store', type=str)
    args = parser.parse_args()

    input_arg = args.input
    input_path = os.path.expanduser(input_arg)
    print("Input: " + input_path)
    if not os.path.exists(input_path):
        print('The path specified does not exist')
        sys.exit()

    output_arg = args.output
    output_path = os.getcwd()
    print("Output: " + output_path)
    if output_arg: 
        output_path = os.path.expanduser(output_arg)

    figure = pyplot.figure()
    axes = mplot3d.Axes3D(figure)

    your_mesh = mesh.Mesh.from_file(input_path)
    axes.add_collection3d(mplot3d.art3d.Poly3DCollection(your_mesh.vectors))
    scale = your_mesh.points.flatten(-1)
    axes.auto_scale_xyz(scale, scale, scale)
    pyplot.show()
