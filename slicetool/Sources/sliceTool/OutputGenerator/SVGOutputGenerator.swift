import Foundation
import VectorMath

private final class SVGOutputGenerator: OutputGeneratorType {
    func generate(polygons: [[Vector2]], gmin: Vector2, gmax: Vector2) -> Data? {
        guard polygons.count > 0 else { return nil }
        var string = ""

        let newPolygons = polygons.map { polygon -> [Vector2] in
            return polygon.map { point -> Vector2 in
                Vector2(point.x - gmin.x + 50, point.y - gmin.y + 50 )
            }
        }

        let w = gmax.x - gmin.x + 50 * 2
        let h = gmax.y - gmin.y + 50 * 2

        string.append("<svg version=\"1.1\" width=\"\(w)\" height=\"\(h)\" baseProfile=\"full\" xmlns=\"http://www.w3.org/2000/svg\">")

        for polygon in newPolygons {

            let pointsStr = polygon.reduce("") { str, p in
                return str + "\(p.x),\(p.y) "
            }
            string.append("<polyline points=\"\(pointsStr)\" style=\"fill:none;stroke:black;stroke-width:1\" />\n")
        }
        string.append("</svg>")
        return string.data(using: .utf8)
    }
}

extension OutputGenerator {
    static let svg: OutputGeneratorType = SVGOutputGenerator()
}
