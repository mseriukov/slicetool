import VectorMath

struct Triangle {
    let v1: Vertex
    let v2: Vertex
    let v3: Vertex
    let n: Vector3

    init(v1: Vertex, v2: Vertex, v3: Vertex, n: Vector3) {
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
        self.n = n
    }
}
