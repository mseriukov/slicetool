import Foundation
import simd
import CoreGraphics

func slice(mesh: Mesh, z: Float) -> [(float2, float2)] {
    var result: [(float2, float2)] = []
    let verticies = mesh.verticies

    let zStart = mesh.boundingBox.bottomLeftRear[2]

    let zSlice = zStart + z

    let plane = Plane(p: float3(0, 0, zSlice), n: float3(0, 0, 1))

    for i in stride(from: 0, to: mesh.verticies.count, by: 3) {
        let v1 = verticies[i + 0]
        let v2 = verticies[i + 1]
        let v3 = verticies[i + 2]

        if v1.position[2] > zSlice && v2.position[2] > zSlice && v3.position[2] > zSlice {
            continue
        }
        if v1.position[2] < zSlice && v2.position[2] < zSlice && v3.position[2] < zSlice {
            continue
        }


        var touch: Int = 0

        let t1 = Float.equal(v1.position[2], zSlice, precise: 10)
        let t2 = Float.equal(v2.position[2], zSlice, precise: 10)
        let t3 = Float.equal(v3.position[2], zSlice, precise: 10)

        if t1  {
            touch += 1
        }
        if t2 {
            touch += 1
        }
        if t3 {
            touch += 1
        }

        if touch == 3 {
            continue
        }

        if touch == 2 {
            if t1 && t2 && !t3 {
                result.append((float2(v1.position[0],v1.position[1]), float2(v2.position[0],v2.position[1])))
            } else if !t1 && t2 && t3 {
                result.append((float2(v2.position[0],v2.position[1]), float2(v3.position[0],v3.position[1])))
            } else {
                result.append((float2(v3.position[0],v3.position[1]), float2(v1.position[0],v1.position[1])))
            }
            continue
        }

        if touch == 1 {
            if t1 && ((v2.position[2] > zSlice && v3.position[2] < zSlice) || (v2.position[2] < zSlice && v3.position[2] > zSlice)) {
                if let intersect = plane.intersectLine(Line(p0: v2.position, p1: v3.position)) {
                    result.append((float2(intersect[0], intersect[1]), float2(v1.position[0], v1.position[1])))
                }
            } else if t2 && ((v3.position[2] > zSlice && v1.position[2] < zSlice) || (v3.position[2] < zSlice && v1.position[2] > zSlice)) {
                if let intersect = plane.intersectLine(Line(p0: v3.position, p1: v1.position)) {
                    result.append((float2(intersect[0], intersect[1]), float2(v2.position[0], v2.position[1])))
                }
            } else if t3 && ((v1.position[2] > zSlice && v2.position[2] < zSlice) || (v1.position[2] < zSlice && v2.position[2] > zSlice)) {
                if let intersect = plane.intersectLine(Line(p0: v1.position, p1: v2.position)) {
                    result.append((float2(intersect[0], intersect[1]), float2(v3.position[0], v3.position[1])))
                }
            }
            continue
        }

        if touch == 0 {
            var top: [float3] = []
            var bot: [float3] = []

            v1.position[2] > zSlice ? top.append(v1.position) : bot.append(v1.position)
            v2.position[2] > zSlice ? top.append(v2.position) : bot.append(v2.position)
            v3.position[2] > zSlice ? top.append(v3.position) : bot.append(v3.position)

            if top.count == 1 {
                if let intersect1 = plane.intersectLine(Line(p0: top[0], p1: bot[0])),
                   let intersect2 = plane.intersectLine(Line(p0: top[0], p1: bot[1])) {
                    result.append((float2(intersect1[0], intersect1[1]), float2(intersect2[0], intersect2[1])))
                }
            } else {
                if let intersect1 = plane.intersectLine(Line(p0: top[0], p1: bot[0])),
                   let intersect2 = plane.intersectLine(Line(p0: top[1], p1: bot[0])){
                    result.append((float2(intersect1[0], intersect1[1]), float2(intersect2[0], intersect2[1])))
                }
            }


        }
    }
    return result
}

func linesToPolygons(_ lines: [(float2, float2)]) -> [[float2]] {
    guard lines.count > 3 else { return [] }
    var polygons: [[float2]] = []

    var polygon: [float2] = []

    var lines = lines

    func getNextPoint(_ lines: inout [(float2, float2)], firstPoint: float2, lastPoint: inout float2, polygon: inout [float2]) -> Bool {
        var found = false

        var newLines: [(float2, float2)?] = lines

        for i in 0..<lines.count {
            let line = lines[i]
            if isSamePoint(lastPoint, line.0) {
                newLines[i] = nil
                let otherPoint = line.1
                if isSamePoint(firstPoint, otherPoint) {
                    polygon.append(otherPoint) // For polyline
                    break
                }
                polygon.append(otherPoint)
                lastPoint = otherPoint
                found = true
                
            } else if isSamePoint(lastPoint, line.1) {
                newLines[i] = nil
                let otherPoint = line.0
                if isSamePoint(firstPoint, otherPoint) {
                    polygon.append(otherPoint) // For polyline
                    break
                }
                polygon.append(otherPoint)
                lastPoint = otherPoint
                found = true

            }
        }

        lines = newLines.compactMap { $0 }
        return found
    }

    while lines.count > 0 {
        let firstPoint: float2 = lines[0].0
        var lastPoint: float2 = lines[0].1
        lines.removeFirst()
        polygon.append(firstPoint)
        polygon.append(lastPoint)

        while getNextPoint(&lines, firstPoint: firstPoint, lastPoint: &lastPoint, polygon: &polygon) { }

        polygons.append(polygon)
        polygon = []
    }

    return polygons
}

func writeLinesToSvg(_ polygons: [[float2]], gmin: float2, gmax: float2, z: Float, sliceURL: URL) {
    let url = sliceURL.appendingPathComponent("slice_\(Int(z)).svg")
    var string = ""

    guard polygons.count > 0 else { return }

    let newPolygons = polygons.map { polygon -> [float2] in
        return polygon.map { point -> float2 in
            float2( point[0] - gmin[0]+50, point[1] - gmin[1]+50 )
        }
    }

    let w = gmax[0] - gmin[0]+50*2
    let h = gmax[1] - gmin[1]+50*2

    string.append("<svg version=\"1.1\" width=\"\(w)\" height=\"\(h)\" baseProfile=\"full\" xmlns=\"http://www.w3.org/2000/svg\">")

    for polygon in newPolygons {

        let pointsStr = polygon.reduce("") { str, p in
            return str + "\(p[0]),\(p[1]) "
        }
        string.append("<polyline points=\"\(pointsStr)\" style=\"fill:none;stroke:black;stroke-width:1\" />\n")
    }
//    for line in newLines {
//        string.append("<line x1=\"\(line.0[0])\" y1=\"\(line.0[1])\" x2=\"\(line.1[0])\" y2=\"\(line.1[1])\" style=\"stroke:rgb(255,0,0);stroke-width:1\" />")
//    }

    //string.append("<polyline points=\"\(pointsStr)\" style=\"fill:none;stroke:black;stroke-width:1\" />")
    string.append("</svg>")

    try? string.write(to: url, atomically: true, encoding: .utf8)


}

func writeLinesToGcode(_ polygons: [[float2]], gmin: float2, gmax: float2, z: Float, sliceURL: URL) {
    let url = sliceURL.appendingPathComponent("slice_\(Int(z)).gcode")
    var string = ""

    guard polygons.count > 0 else { return }

    let newPolygons = polygons.map { polygon -> [float2] in
        return polygon.map { point -> float2 in
            float2( point[0] - gmin[0]+50, point[1] - gmin[1]+50 )
        }
    }

    let w = gmax[0] - gmin[0]+50*2
    let h = gmax[1] - gmin[1]+50*2

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

    try? string.write(to: url, atomically: true, encoding: .utf8)


}


let arguments = CommandLine.arguments
guard arguments.count > 1 else { fatalError() }

let url = URL(fileURLWithPath: arguments[1])
let parser = STLParser()
let verticies = parser.parseSTL(url)

let mesh = Mesh()
mesh.addVerticies(verticies)

let zmin = mesh.boundingBox.bottomLeftRear[2]
let zmax = mesh.boundingBox.topRightFront[2]

let height = zmax - zmin

let sliceURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("slice")
try? FileManager.default.createDirectory(at: sliceURL, withIntermediateDirectories: true, attributes: [:])

for z in stride(from: 0, to: height, by: 2) {

    var lines = slice(mesh: mesh, z: Float(z))
    let polygons = linesToPolygons(lines)

    let gmax = float2(mesh.boundingBox.topRightFront[0], mesh.boundingBox.topRightFront[1])
    let gmin = float2(mesh.boundingBox.bottomLeftRear[0], mesh.boundingBox.bottomLeftRear[1])

    let w = gmax[0] - gmin[0]+50*2
    let h = gmax[1] - gmin[1]+50*2

    writeLinesToSvg(polygons, gmin: gmin, gmax: gmax, z: z, sliceURL: sliceURL)
    //polygonsToImage(size: CGSize(width: Double(w), height: Double(h)), gmin: gmin, gmax: gmax, polygons: polygons, z: z, sliceURL: sliceURL)
    //writeLinesToGcode(polygons, gmin: gmin, gmax: gmax, z: z, sliceURL: sliceURL)
}
