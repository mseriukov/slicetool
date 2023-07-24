import Foundation
import VectorMath

private final class GCODEOutputGenerator: OutputGeneratorType {
    func generate(polylines: [Polyline2], gmin: Vector2, gmax: Vector2) -> Data? {
        guard polylines.count > 0 else { return nil }
        var string = ""

        let newPolygons = polylines.map { polyline -> [Vector2] in
            return polyline.map { point -> Vector2 in
                Vector2(point.x - gmin.x + 50, point.y - gmin.y + 50 )
            }
        }

        string.append("G90 G21\n")
        string.append("M3\n")

        for polygon in newPolygons {
            if let polygon = polygon.first {
                string.append("G00 X\(polygon.x) Y\(polygon.y) Z\(0) S\(0)\n")
            }
            for point in polygon {
                string.append("G01 X\(point.x) Y\(point.y) Z\(0) S\(100)\n")
            }
        }
        return string.data(using: .utf8)
    }
}

extension OutputGenerator {
    static let gcode: OutputGeneratorType = GCODEOutputGenerator()
}
