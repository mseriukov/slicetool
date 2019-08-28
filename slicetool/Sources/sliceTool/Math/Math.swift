import Foundation
import VectorMath

extension Float32 {
    func precised(_ value: Int = 1) -> Float {
        let offset = pow(10, Float(value))
        return (self * offset).rounded() / offset
    }

    static func equal(_ lhs: Float32, _ rhs: Float32, precise value: Int? = nil) -> Bool {
        guard let value = value else {
            return lhs == rhs
        }

        return lhs.precised(value) == rhs.precised(value)
    }
}

func isSamePoint(_ p1: Vector2, _ p2: Vector2) -> Bool {
    return Float32.equal(p1.x, p2.x, precise: 6) && Float32.equal(p1.y, p2.y, precise: 6)
}


struct Plane {
    var p: Vector3
    var n: Vector3

    func distanceToPoint(_ p: Vector3) -> Float {
        return abs(n.dot(p - self.p))
    }

    func intersectLine(_ line: Line) -> Vector3? {
        let u = line.p1 - line.p0
        let dt = n.dot(u)
        if Float.equal(abs(dt), 0, precise: 6) {
            return nil
        } else {
            let w = self.p - line.p0
            return line.p0 + u * n.dot(w) / dt
        }
    }
}


struct Line {
    var p0: Vector3
    var p1: Vector3
}
