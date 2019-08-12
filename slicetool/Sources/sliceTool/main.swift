import Foundation

func output(polygons: [[Vec2]], gmin: Vec2, gmax: Vec2, z: Float32, url: URL, filenameFormat: String, generator: OutputGeneratorType) {
    guard let data = generator.generate(polygons: polygons, gmin: gmin, gmax: gmax) else {
        return
    }
    let filename = String(format: filenameFormat, "\(Int(z))")
    let destinationURL = url.appendingPathComponent(filename)
    try? data.write(to: destinationURL, options: [.atomicWrite])
}

func main() {
    let arguments = CommandLine.arguments
    guard arguments.count > 1 else { fatalError() }

    let url = URL(fileURLWithPath: arguments[1])
    let parser = STLParser()
    let verticies = parser.parseSTL(url)

    let mesh = Mesh()
    mesh.addVerticies(verticies)

    let zmin = mesh.boundingBox.bottomLeftRear.z
    let zmax = mesh.boundingBox.topRightFront.z

    let height = zmax - zmin

    let filename = url.lastPathComponent
    let sliceURL = url.deletingLastPathComponent().appendingPathComponent("slice-\(filename)")
    try? FileManager.default.createDirectory(at: sliceURL, withIntermediateDirectories: true, attributes: [:])

    let slicer: SlicerType = Slicer()

    for z in stride(from: 0, to: height, by: 2) {
        let polygons = slicer.slice(mesh: mesh, z: Float(z))

        let gmax = Vec2(x: mesh.boundingBox.topRightFront.x, y: mesh.boundingBox.topRightFront.y)
        let gmin = Vec2(x: mesh.boundingBox.bottomLeftRear.x, y: mesh.boundingBox.bottomLeftRear.y)

        output(polygons: polygons, gmin: gmin, gmax: gmax, z: z, url: sliceURL, filenameFormat: "slice_%@.svg", generator: OutputGenerator.svg)
        output(polygons: polygons, gmin: gmin, gmax: gmax, z: z, url: sliceURL, filenameFormat: "slice_%@.gcode", generator: OutputGenerator.gcode)
    }
}

main()
