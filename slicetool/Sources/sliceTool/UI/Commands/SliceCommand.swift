import Foundation
import SPMUtility
import Basic
import VectorMath

enum MyError: Error {
    case runtimeError(String)
}

enum OutputType: String, Codable {
    case svg
    case gcode
}

extension OutputType: StringEnumArgument {
    static let completion: ShellCompletion = .values([
        (svg.rawValue, "SVG output type"),
        (gcode.rawValue, "GCODE output type")
    ])
}

extension Float32: ArgumentKind {
    public static var completion: ShellCompletion { return .none }

    public init(argument: String) throws {
        self.init()
        if let float = Float32(argument) {
            self = float
        } else {
            throw MyError.runtimeError("Float parsing failed!")
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

struct SliceToSVGCommand: Command {
    let command = "slice"
    let overview = "slices an STL to the required output."

    private let input: PositionalArgument<PathArgument>
    private let output: OptionArgument<PathArgument>
    private let outputTypes: OptionArgument<[OutputType]>
    private let sliceIncrement: OptionArgument<Float32>

    init(parser: ArgumentParser) {
        let subparser = parser.add(subparser: command, overview: overview)
        output = subparser.add(
            option: "--output",
            shortName: "-o",
            kind: PathArgument.self,
            usage: "output directory. [default: Relative to STL]"
        )

        outputTypes = subparser.add(
            option: "--output-type",
            shortName: "-t",
            kind: [OutputType].self,
            strategy: .oneByOne,
            usage: "Output type. (svg, gcode) [default: svg]"
        )

        sliceIncrement = subparser.add(
            option: "--slice-increment",
            shortName: "-i",
            kind: Float32.self,
            usage: "Slice increment value. (X mm) [default: 1.0]"
        )

        input = subparser.add(positional: "input", kind: PathArgument.self)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        guard let input = arguments.get(input) else {
            return
        }

        let url = input.path.asURL
        let parser = STLParser()
        guard let mesh = parser.parseSTL(url) else { return }

        let zmin = mesh.boundingBox.bottomLeftRear.z
        let zmax = mesh.boundingBox.topRightFront.z

        let height = zmax - zmin

        let toURL = arguments.get(output)?.path.asURL ?? url.deletingLastPathComponent()

        let filename = url.lastPathComponent
        let sliceURL = toURL.appendingPathComponent("slice-\(filename)")
        try? FileManager.default.createDirectory(at: sliceURL, withIntermediateDirectories: true, attributes: [:])
        let slicer: SlicerType = Slicer()

        let increment = arguments.get(sliceIncrement) ?? 1.0

        for z in stride(from: 0.0, to: height, by: increment) {
            let polygons = slicer.slice(mesh: mesh, z: z)
            
            let gmax = Vector2(mesh.boundingBox.topRightFront.x, mesh.boundingBox.topRightFront.y)
            let gmin = Vector2(mesh.boundingBox.bottomLeftRear.x, mesh.boundingBox.bottomLeftRear.y)

            let types = arguments.get(outputTypes) ?? [.svg]
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

}
