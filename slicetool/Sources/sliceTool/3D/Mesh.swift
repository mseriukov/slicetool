import Foundation

struct BoundingBox {
    var bottomLeftRear: Vec3 = Vec3(value: 0)
    var topRightFront: Vec3 = Vec3(value: 0)
}

class Mesh {
    var boundingBox: BoundingBox = BoundingBox()
    var verticies: [Vertex] = []

    func addVertex(_ vertex: Vertex) {
        verticies.append(vertex)
        if verticies.count == 1 {
            boundingBox.bottomLeftRear = vertex.position
            boundingBox.topRightFront = vertex.position
        } else {
            if vertex.position.x < boundingBox.bottomLeftRear.x {
                boundingBox.bottomLeftRear.x = vertex.position.x
            }

            if vertex.position.y < boundingBox.bottomLeftRear.y {
                boundingBox.bottomLeftRear.y = vertex.position.y
            }

            if vertex.position.z < boundingBox.bottomLeftRear.z {
                boundingBox.bottomLeftRear.z = vertex.position.z
            }

            if vertex.position.x > boundingBox.topRightFront.x {
                boundingBox.topRightFront.x = vertex.position.x
            }

            if vertex.position.y > boundingBox.topRightFront.y {
                boundingBox.topRightFront.y = vertex.position.y
            }

            if vertex.position.z > boundingBox.topRightFront.z {
                boundingBox.topRightFront.z = vertex.position.z
            }
        }
    }

    func addVerticies(_ verticies: [Vertex]) {
        verticies.forEach(addVertex)
    }

}
