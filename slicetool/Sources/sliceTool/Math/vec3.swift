import Foundation

struct Vec3 {
    var x: Float32 = 0.0
    var y: Float32 = 0.0
    var z: Float32 = 0.0
    
    init() {
        x = 0.0
        y = 0.0
        z = 0.0
    }
    
    init(value: Float32) {
        x = value
        y = value
        z = value
    }
    
    init(x: Float32, y: Float32, z: Float32) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(other: Vec3) {
        x = other.x
        y = other.y
        z = other.z
    }
}

extension Vec3 {
    
    func distance(other: Vec3) -> Float32 {
        let result = self - other
        return sqrt(result.dot(result))
    }
    
    mutating func normalize() {
        let m = magnitude()
        
        if m > 0 {
            let il: Float32 = 1.0 / m
            
            x *= il
            y *= il
            z *= il
        }
    }
    
    func magnitude() -> Float32 {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func dot(_ v: Vec3 ) -> Float32 {
        return x * v.x + y * v.y + z * v.z
    }
    
    mutating func lerp(a: Vec3, b: Vec3, coef: Float32) {
        let result = a + (b - a) * coef
        
        x = result.x
        y = result.y
        z = result.z
    }
}

extension Vec3 {

    static func ==(lhs: Vec3, rhs: Vec3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }

    static func * (lhs: Vec3, rhs: Float32) -> Vec3 {
        return Vec3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }

    static func * (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }

    static func / (lhs: Vec3, rhs: Float32) -> Vec3 {
        return Vec3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }

    static func / (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }

    static func + (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func - (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    static func + (lhs: Vec3, rhs: Float32) -> Vec3 {
        return Vec3(x: lhs.x + rhs, y: lhs.y + rhs, z: lhs.z + rhs)
    }

    static func - (lhs: Vec3, rhs: Float32) -> Vec3 {
        return Vec3(x: lhs.x - rhs, y: lhs.y - rhs, z: lhs.z - rhs)
    }

    static func += (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs - rhs
    }

    static func *= (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs / rhs
    }
}
