import Foundation
import VectorMath

func isSamePoint(_ p1: Vector2, _ p2: Vector2) -> Bool {
    p1.x.isAlmostEqual(to: p2.x) && p1.y.isAlmostEqual(to: p2.y)
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
        if dt.isAlmostZero() {
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
