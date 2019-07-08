from setuptools import setup

setup(
    name='slicetool',
    version=1.0,
    packages=['slicetool'],
    install_requires=[
        'numpy-stl',
        'matplotlib',
        'meshcut'
    ],
    entry_points={'console_scripts': ['slicetool = slicetool.main:main']}
)