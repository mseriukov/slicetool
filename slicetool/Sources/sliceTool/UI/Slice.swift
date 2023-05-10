import ArgumentParser
import Foundation
import VectorMath

//private let input: PositionalArgument<PathArgument>
//private let output: OptionArgument<PathArgument>
//private let outputTypes: OptionArgument<[OutputType]>
//private let sliceIncrement: OptionArgument<Float32>
//
//init(parser: ArgumentParser) {
//    let subparser = parser.add(subparser: command, overview: overview)
//    output = subparser.add(
//        option: "--output",
//        shortName: "-o",
//        kind: PathArgument.self,
//        usage: "output directory. [default: Relative to STL]"
//    )
//
//    outputTypes = subparser.add(
//        option: "--output-type",
//        shortName: "-t",
//        kind: [OutputType].self,
//        strategy: .oneByOne,
//        usage: "Output type. (svg, gcode) [default: svg]"
//    )
//
//    sliceIncrement = subparser.add(
//        option: "--slice-increment",
//        shortName: "-i",
//        kind: Float32.self,
//        usage: "Slice increment value. (X mm) [default: 1.0]"
//    )
enum MyError: Error {
    case runtimeError(String)
}

enum OutputType: String, Codable {
    case svg
    case gcode
}

extension OutputType: ExpressibleByArgument { }


@main
struct Slice: ParsableCommand {
    @Argument(
        help: "Input file path.",
        completion: .file(),
        transform: URL.init(fileURLWithPath:)
    )
    var inputFile: URL? = nil

    @Option(
        name: .customShort("o"),
        help: "Output path. [default: Relative to STL]",
        completion: .file(),
        transform: URL.init(fileURLWithPath:)
    )
    var outputFile: URL? = nil

    @Option(
        name: .customShort("t"),
        help: "Output type. (svg, gcode) [default: svg]"
    )
    var outputTypes: [OutputType] = [.svg]

    @Option(
        name: .customShort("i"),
        help: "Slice increment value. (X mm) [default: 1.0]"
    )
    var sliceIncrement: Float32 = 1.0

    @Option(
        name: .customShort("s"),
        help: "Slice scale value. [default: 1.0]"
    )
    var sliceScale: Float32 = 1.0

    @Option(help: "Only count lines with this prefix.")
    var prefix: String? = nil

    @Flag(help: "Include extra information in the output.")
    var verbose = false
}

extension Slice {

    mutating func run() throws {
        guard let inputFile else {
            print("123")
            return
        }
        let parser = STLParser()
        guard let mesh = parser.parseSTL(inputFile, scale: sliceScale) else { return }

        let zmin = mesh.boundingBox.bottomLeftRear.z
        let zmax = mesh.boundingBox.topRightFront.z

        let height = zmax - zmin
        print("Height: \(height)")

        let toURL = outputFile ?? inputFile.deletingLastPathComponent()

        let filename = inputFile.lastPathComponent
        let sliceURL = toURL.appendingPathComponent("slice-\(filename)")
        try? FileManager.default.createDirectory(at: sliceURL, withIntermediateDirectories: true, attributes: [:])
        let slicer: SlicerType = Slicer()

        let increment = sliceIncrement

        for z in stride(from: 0.0, to: height, by: increment) {
            let polygons = slicer.slice(mesh: mesh, z: z)

            let gmax = Vector2(mesh.boundingBox.topRightFront.x, mesh.boundingBox.topRightFront.y)
            let gmin = Vector2(mesh.boundingBox.bottomLeftRear.x, mesh.boundingBox.bottomLeftRear.y)

            let types = outputTypes
            for type in types {
                switch type {
                case .svg:
                    generateOutput(polygons: polygons, gmin: gmin, gmax: gmax, z: z, url: sliceURL, filenameFormat: "slice_%0.2f.svg", generator: OutputGenerator.svg)
                case .gcode:
                    generateOutput(polygons: polygons, gmin: gmin, gmax: gmax, z: z, url: sliceURL, filenameFormat: "slice_%0.2f.gcode", generator: OutputGenerator.gcode)
                }
            }
        }
    }

    func generateOutput(polygons: [[Vector2]], gmin: Vector2, gmax: Vector2, z: Float32, url: Foundation.URL, filenameFormat: String, generator: OutputGeneratorType) {
        guard let data = generator.generate(polygons: polygons, gmin: gmin, gmax: gmax) else {
            return
        }
        let filename = String(format: filenameFormat, z)
        let destinationURL = url.appendingPathComponent(filename)
        try? data.write(to: destinationURL, options: [.atomicWrite])
    }
}

