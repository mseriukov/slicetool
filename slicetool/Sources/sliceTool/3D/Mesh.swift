import Foundation

struct BoundingBox {
    var bottomLeftRear: Vec3 = Vec3(value: 0)
    var topRightFront: Vec3 = Vec3(value: 0)
}

class Mesh {
    var boundingBox: BoundingBox = BoundingBox()
    var triangles: [Triangle] = []

    func addTriangle(_ t: Triangle) {
        triangles.append(t)
        addVertex(t.v1)
        addVertex(t.v2)
        addVertex(t.v3)
    }
}

private extension Mesh {

    func addVertex(_ vertex: Vertex) {
        let p = vertex.position

        boundingBox.bottomLeftRear.x = min(boundingBox.bottomLeftRear.x, p.x)
        boundingBox.bottomLeftRear.y = min(boundingBox.bottomLeftRear.y, p.y)
        boundingBox.bottomLeftRear.z = min(boundingBox.bottomLeftRear.z, p.z)

        boundingBox.topRightFront.x = max(boundingBox.topRightFront.x, p.x)
        boundingBox.topRightFront.y = max(boundingBox.topRightFront.y, p.y)
        boundingBox.topRightFront.z = max(boundingBox.topRightFront.z, p.z)
    }

}
