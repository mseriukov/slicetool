import simd

extension Double {
    func precised(_ value: Int = 1) -> Double {
        let offset = pow(10, Double(value))
        return (self * offset).rounded() / offset
    }

    static func equal(_ lhs: Double, _ rhs: Double, precise value: Int? = nil) -> Bool {
        guard let value = value else {
            return lhs == rhs
        }

        return lhs.precised(value) == rhs.precised(value)
    }
}

extension Float {
    func precised(_ value: Int = 1) -> Float {
        let offset = pow(10, Float(value))
        return (self * offset).rounded() / offset
    }

    static func equal(_ lhs: Float, _ rhs: Float, precise value: Int? = nil) -> Bool {
        guard let value = value else {
            return lhs == rhs
        }

        return lhs.precised(value) == rhs.precised(value)
    }
}

func isSamePoint(_ p1: float2, _ p2: float2) -> Bool {
    return Float.equal(p1.x, p2.x, precise: 6) && Float.equal(p1.y, p2.y, precise: 6)
}


struct Plane {
    var p: float3
    var n: float3

    func distanceToPoint(_ p: float3) -> Float {
        return abs(dot(n, p - self.p))
    }

    func intersectLine(_ line: Line) -> float3? {
        let u = line.p1 - line.p0
        let dt = dot(n, u)
        if Float.equal(abs(dt), 0, precise: 6) {
            return nil
        } else {
            let w = self.p - line.p0
            return line.p0 + u * dot(n, w) / dt
        }
    }
}


struct Line {
    var p0: float3
    var p1: float3
}
