import ArgumentParser
import Foundation
import VectorMath

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
            // TODO: Handle error.
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

        let progressBar = ProgressBar()
        progressBar.count = Int(height)
        for z in stride(from: 0.0, to: height, by: increment) {
            let polylines = slicer.slice(mesh: mesh, z: z)

            let lens = polylines.map { Int($0.calculateLength()) }
                .sorted(by: >)
                .map { "\($0)" }
                .joined(separator: ", ")


            progressBar.filled = Int(z)
            let gmax = Vector2(mesh.boundingBox.topRightFront.x, mesh.boundingBox.topRightFront.y)
            let gmin = Vector2(mesh.boundingBox.bottomLeftRear.x, mesh.boundingBox.bottomLeftRear.y)

            let types = outputTypes
            for type in types {
                switch type {
                case .svg:
                    generateOutput(polylines: polylines, gmin: gmin, gmax: gmax, z: z, url: sliceURL, filenameFormat: "slice_%0.2f.svg", generator: OutputGenerator.svg)
                case .gcode:
                    generateOutput(polylines: polylines, gmin: gmin, gmax: gmax, z: z, url: sliceURL, filenameFormat: "slice_%0.2f.gcode", generator: OutputGenerator.gcode)
                }
            }
        }
    }

    func generateOutput(polylines: [Polyline2], gmin: Vector2, gmax: Vector2, z: Float32, url: Foundation.URL, filenameFormat: String, generator: OutputGeneratorType) {
        guard let data = generator.generate(polylines: polylines, gmin: gmin, gmax: gmax) else {
            return
        }
        let filename = String(format: filenameFormat, z)
        let destinationURL = url.appendingPathComponent(filename)
        try? data.write(to: destinationURL, options: [.atomicWrite])
    }
}
