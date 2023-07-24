# sliceTool

A tool that allows to to slice an STL model into SVG slices with a given increment and scale.
Was intended to help me with one of my DIY projects. 
Implementation is made as simple as possible and thus is very slow but is very easy to maintain if needed.

## How to use:

```
git clone https://github.com/mseriukov/sliceTool.git
cd sliceTool
swift run slicetool -i 5 -s 3 -o ~/Desktop bunny.stl
``` 
