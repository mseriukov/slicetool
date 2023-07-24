import Foundation
import VectorMath

final class Slicer: SlicerType {

    func slice(mesh: Mesh, z: Float) -> [Polyline2] {
        linesToPolylines(slice(mesh: mesh, z: z))
    }

}

private extension Slicer {

    func slice(mesh: Mesh, z: Float) -> [Line2] {
        var result: [Line2] = []
        let triangles = mesh.triangles

        let zStart = mesh.boundingBox.bottomLeftRear.z
        let zSlice = zStart + z

        let plane = Plane(p: Vector3(0, 0, zSlice), n: Vector3(0, 0, 1))

        for t in triangles {
            let v1 = t.v1
            let v2 = t.v2
            let v3 = t.v3

            if v1.position.z > zSlice && v2.position.z > zSlice && v3.position.z > zSlice {
                continue
            }
            if v1.position.z < zSlice && v2.position.z < zSlice && v3.position.z < zSlice {
                continue
            }

            var touch: Int = 0

            let t1 = v1.position.z.isAlmostEqual(to: zSlice)
            let t2 = v2.position.z.isAlmostEqual(to: zSlice)
            let t3 = v3.position.z.isAlmostEqual(to: zSlice)

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
                    result.append(Line2(p0: Vector2(v1.position.x, v1.position.y), p1: Vector2(v2.position.x, v2.position.y)))
                } else if !t1 && t2 && t3 {
                    result.append(Line2(p0: Vector2(v2.position.x, v2.position.y), p1: Vector2(v3.position.x, v3.position.y)))
                } else {
                    result.append(Line2(p0: Vector2(v3.position.x, v3.position.y), p1: Vector2(v1.position.x, v1.position.y)))
                }
                continue
            }

            if touch == 1 {
                if t1 && ((v2.position.z > zSlice && v3.position.z < zSlice) || (v2.position.z < zSlice && v3.position.z > zSlice)) {
                    if let intersect = plane.intersectLine(Line3(p0: v2.position, p1: v3.position)) {
                        result.append(Line2(p0: Vector2(intersect.x, intersect.y), p1: Vector2(v1.position.x, v1.position.y)))
                    }
                } else if t2 && ((v3.position.z > zSlice && v1.position.z < zSlice) || (v3.position.z < zSlice && v1.position.z > zSlice)) {
                    if let intersect = plane.intersectLine(Line3(p0: v3.position, p1: v1.position)) {
                        result.append(Line2(p0: Vector2(intersect.x, intersect.y), p1: Vector2(v2.position.x, v2.position.y)))
                    }
                } else if t3 && ((v1.position.z > zSlice && v2.position.z < zSlice) || (v1.position.z < zSlice && v2.position.z > zSlice)) {
                    if let intersect = plane.intersectLine(Line3(p0: v1.position, p1: v2.position)) {
                        result.append(Line2(p0: Vector2(intersect.x, intersect.y), p1: Vector2(v3.position.x, v3.position.y)))
                    }
                }
                continue
            }

            if touch == 0 {
                var top: [Vector3] = []
                var bot: [Vector3] = []

                v1.position.z > zSlice ? top.append(v1.position) : bot.append(v1.position)
                v2.position.z > zSlice ? top.append(v2.position) : bot.append(v2.position)
                v3.position.z > zSlice ? top.append(v3.position) : bot.append(v3.position)

                if top.count == 1 {
                    if let intersect1 = plane.intersectLine(Line3(p0: top[0], p1: bot[0])),
                        let intersect2 = plane.intersectLine(Line3(p0: top[0], p1: bot[1])) {
                        result.append(Line2(p0: Vector2(intersect1.x, intersect1.y), p1: Vector2(intersect2.x, intersect2.y)))
                    }
                } else {
                    if let intersect1 = plane.intersectLine(Line3(p0: top[0], p1: bot[0])),
                        let intersect2 = plane.intersectLine(Line3(p0: top[1], p1: bot[0])){
                        result.append(Line2(p0: Vector2(intersect1.x, intersect1.y), p1: Vector2(intersect2.x, intersect2.y)))
                    }
                }


            }
        }
        return result
    }

    func linesToPolylines(_ lines: [Line2]) -> [Polyline2] {
        guard lines.count > 3 else { return [] }
        var polylines: [Polyline2] = []

        var polyline = Polyline2()

        var lines = lines.removeDuplicates()

        func getNextPoint(
            _ lines: inout [Line2],
            firstPoint: Vector2,
            lastPoint: inout Vector2,
            polyline: inout Polyline2
        ) -> Bool {
            var found = false

            var newLines: [Line2?] = lines

            for i in 0..<lines.count {
                let line = lines[i]
                if isSamePoint(lastPoint, line.p0) {
                    newLines[i] = nil
                    let otherPoint = line.p1
                    if isSamePoint(firstPoint, otherPoint) {
                        polyline.append(otherPoint) // For polyline
                        break
                    }
                    polyline.append(otherPoint)
                    lastPoint = otherPoint
                    found = true

                } else if isSamePoint(lastPoint, line.p1) {
                    newLines[i] = nil
                    let otherPoint = line.p0
                    if isSamePoint(firstPoint, otherPoint) {
                        polyline.append(otherPoint) // For polyline
                        break
                    }
                    polyline.append(otherPoint)
                    lastPoint = otherPoint
                    found = true

                }
            }

            lines = newLines.compactMap { $0 }
            return found
        }

        while lines.count > 0 {
            let firstPoint: Vector2 = lines[0].p0
            var lastPoint: Vector2 = lines[0].p1
            lines.removeFirst()
            polyline.append(firstPoint)
            polyline.append(lastPoint)

            while getNextPoint(&lines, firstPoint: firstPoint, lastPoint: &lastPoint, polyline: &polyline) { }

            polylines.append(polyline)
            polyline = Polyline2()
        }

        return polylines
    }

}
