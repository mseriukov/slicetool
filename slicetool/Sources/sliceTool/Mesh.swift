import Foundation
import simd

struct BoundingBox {
    var bottomLeftRear: float3 = float3(0)
    var topRightFront: float3 = float3(0)
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
            if vertex.position[0] < boundingBox.bottomLeftRear[0] {
                boundingBox.bottomLeftRear[0] = vertex.position[0]
            }

            if vertex.position[1] < boundingBox.bottomLeftRear[1] {
                boundingBox.bottomLeftRear[1] = vertex.position[1]
            }

            if vertex.position[2] < boundingBox.bottomLeftRear[2] {
                boundingBox.bottomLeftRear[2] = vertex.position[2]
            }

            if vertex.position[0] > boundingBox.topRightFront[0] {
                boundingBox.topRightFront[0] = vertex.position[0]
            }

            if vertex.position[1] > boundingBox.topRightFront[1] {
                boundingBox.topRightFront[1] = vertex.position[1]
            }

            if vertex.position[2] > boundingBox.topRightFront[2] {
                boundingBox.topRightFront[2] = vertex.position[2]
            }
        }
    }

    func addVerticies(_ verticies: [Vertex]) {
        verticies.forEach(addVertex)
    }

}
