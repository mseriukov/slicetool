import Foundation

private final class GCODEOutputGenerator: OutputGeneratorType {
    func generate(polygons: [[Vec2]], gmin: Vec2, gmax: Vec2) -> Data? {
        guard polygons.count > 0 else { return nil }
        var string = ""

        let newPolygons = polygons.map { polygon -> [Vec2] in
            return polygon.map { point -> Vec2 in
                Vec2(x: point.x - gmin.x + 50, y: point.y - gmin.y + 50 )
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
