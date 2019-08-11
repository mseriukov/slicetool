import Foundation

func slice(mesh: Mesh, z: Float) -> [(Vec2, Vec2)] {
    var result: [(Vec2, Vec2)] = []
    let verticies = mesh.verticies

    let zStart = mesh.boundingBox.bottomLeftRear.z

    let zSlice = zStart + z

    let plane = Plane(p: Vec3(x: 0, y: 0, z: zSlice), n: Vec3(x: 0, y: 0, z: 1))

    for i in stride(from: 0, to: mesh.verticies.count, by: 3) {
        let v1 = verticies[i + 0]
        let v2 = verticies[i + 1]
        let v3 = verticies[i + 2]

        if v1.position.z > zSlice && v2.position.z > zSlice && v3.position.z > zSlice {
            continue
        }
        if v1.position.z < zSlice && v2.position.z < zSlice && v3.position.z < zSlice {
            continue
        }


        var touch: Int = 0

        let t1 = Float.equal(v1.position.z, zSlice, precise: 10)
        let t2 = Float.equal(v2.position.z, zSlice, precise: 10)
        let t3 = Float.equal(v3.position.z, zSlice, precise: 10)

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
                result.append((Vec2(x: v1.position.x, y: v1.position.y), Vec2(x: v2.position.x, y: v2.position.y)))
            } else if !t1 && t2 && t3 {
                result.append((Vec2(x: v2.position.x, y: v2.position.y), Vec2(x: v3.position.x, y: v3.position.y)))
            } else {
                result.append((Vec2(x: v3.position.x, y: v3.position.y), Vec2(x: v1.position.x, y: v1.position.y)))
            }
            continue
        }

        if touch == 1 {
            if t1 && ((v2.position.z > zSlice && v3.position.z < zSlice) || (v2.position.z < zSlice && v3.position.z > zSlice)) {
                if let intersect = plane.intersectLine(Line(p0: v2.position, p1: v3.position)) {
                    result.append((Vec2(x: intersect.x, y: intersect.y), Vec2(x: v1.position.x, y: v1.position.y)))
                }
            } else if t2 && ((v3.position.z > zSlice && v1.position.z < zSlice) || (v3.position.z < zSlice && v1.position.z > zSlice)) {
                if let intersect = plane.intersectLine(Line(p0: v3.position, p1: v1.position)) {
                    result.append((Vec2(x: intersect.x, y: intersect.y), Vec2(x: v2.position.x, y: v2.position.y)))
                }
            } else if t3 && ((v1.position.z > zSlice && v2.position.z < zSlice) || (v1.position.z < zSlice && v2.position.z > zSlice)) {
                if let intersect = plane.intersectLine(Line(p0: v1.position, p1: v2.position)) {
                    result.append((Vec2(x: intersect.x, y: intersect.y), Vec2(x: v3.position.x, y: v3.position.y)))
                }
            }
            continue
        }

        if touch == 0 {
            var top: [Vec3] = []
            var bot: [Vec3] = []

            v1.position.z > zSlice ? top.append(v1.position) : bot.append(v1.position)
            v2.position.z > zSlice ? top.append(v2.position) : bot.append(v2.position)
            v3.position.z > zSlice ? top.append(v3.position) : bot.append(v3.position)

            if top.count == 1 {
                if let intersect1 = plane.intersectLine(Line(p0: top[0], p1: bot[0])),
                   let intersect2 = plane.intersectLine(Line(p0: top[0], p1: bot[1])) {
                    result.append((Vec2(x: intersect1.x, y: intersect1.y), Vec2(x: intersect2.x, y: intersect2.y)))
                }
            } else {
                if let intersect1 = plane.intersectLine(Line(p0: top[0], p1: bot[0])),
                   let intersect2 = plane.intersectLine(Line(p0: top[1], p1: bot[1])){
                    result.append((Vec2(x: intersect1.x, y: intersect1.y), Vec2(x: intersect2.x, y: intersect2.y)))
                }
            }


        }
    }
    return result
}

func linesToPolygons(_ lines: [(Vec2, Vec2)]) -> [[Vec2]] {
    guard lines.count > 3 else { return [] }
    var polygons: [[Vec2]] = []

    var polygon: [Vec2] = []

    var lines = lines

    func getNextPoint(_ lines: inout [(Vec2, Vec2)], firstPoint: Vec2, lastPoint: inout Vec2, polygon: inout [Vec2]) -> Bool {
        var found = false

        var newLines: [(Vec2, Vec2)?] = lines

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
        let firstPoint: Vec2 = lines[0].0
        var lastPoint: Vec2 = lines[0].1
        lines.removeFirst()
        polygon.append(firstPoint)
        polygon.append(lastPoint)

        while getNextPoint(&lines, firstPoint: firstPoint, lastPoint: &lastPoint, polygon: &polygon) { }

        polygons.append(polygon)
        polygon = []
    }

    return polygons
}

func writeLinesToSvg(_ polygons: [[Vec2]], gmin: Vec2, gmax: Vec2, z: Float, sliceURL: URL) {
    let url = sliceURL.appendingPathComponent("slice_\(Int(z)).svg")
    var string = ""

    guard polygons.count > 0 else { return }

    let newPolygons = polygons.map { polygon -> [Vec2] in
        return polygon.map { point -> Vec2 in
            Vec2(x: point.x - gmin.x+50, y: point.y - gmin.y+50 )
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
//    for line in newLines {
//        string.append("<line x1=\"\(line.0[0])\" y1=\"\(line.0[1])\" x2=\"\(line.1[0])\" y2=\"\(line.1[1])\" style=\"stroke:rgb(255,0,0);stroke-width:1\" />")
//    }

    //string.append("<polyline points=\"\(pointsStr)\" style=\"fill:none;stroke:black;stroke-width:1\" />")
    string.append("</svg>")

    try? string.write(to: url, atomically: true, encoding: .utf8)


}

func writeLinesToGcode(_ polygons: [[Vec2]], gmin: Vec2, gmax: Vec2, z: Float, sliceURL: URL) {
    let url = sliceURL.appendingPathComponent("slice_\(Int(z)).gcode")
    var string = ""

    guard polygons.count > 0 else { return }

    let newPolygons = polygons.map { polygon -> [Vec2] in
        return polygon.map { point -> Vec2 in
            Vec2(x: point.x - gmin.x + 50, y: point.y - gmin.y + 50 )
        }
    }

//    let w = gmax[0] - gmin[0]+50*2
//    let h = gmax[1] - gmin[1]+50*2

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

let zmin = mesh.boundingBox.bottomLeftRear.z
let zmax = mesh.boundingBox.topRightFront.z

let height = zmax - zmin

let sliceURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("slice")
try? FileManager.default.createDirectory(at: sliceURL, withIntermediateDirectories: true, attributes: [:])

for z in stride(from: 0, to: height, by: 2) {
    let lines = slice(mesh: mesh, z: Float(z))
    let polygons = linesToPolygons(lines)

    let gmax = Vec2(x: mesh.boundingBox.topRightFront.x, y: mesh.boundingBox.topRightFront.y)
    let gmin = Vec2(x: mesh.boundingBox.bottomLeftRear.x, y: mesh.boundingBox.bottomLeftRear.y)

    writeLinesToSvg(polygons, gmin: gmin, gmax: gmax, z: z, sliceURL: sliceURL)
    //writeLinesToGcode(polygons, gmin: gmin, gmax: gmax, z: z, sliceURL: sliceURL)
}
