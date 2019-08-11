import Foundation

struct Vec2 {
    var x: Float32 = 0.0
    var y: Float32 = 0.0
    
    init() {
        x = 0.0
        y = 0.0
    }
    
    init(value: Float32) {
        x = value
        y = value
    }
    
    init(x: Float32, y: Float32) {
        self.x = x
        self.y = y
    }
    
    init(other: Vec2) {
        x = other.x
        y = other.y
    }
}

extension Vec2 {
    
    func distance(other: Vec2) -> Float32 {
        let result = self - other
        return sqrt(result.dot(result))
    }
    
    mutating func normalize() {
        let m = magnitude()
        
        if m > 0 {
            let il: Float32 = 1.0 / m
            
            x *= il
            y *= il
        }
    }
    
    func magnitude() -> Float32 {
        return sqrtf(x*x + y*y)
    }
    
    func dot(_ v: Vec2) -> Float32 {
        return x * v.x + y * v.y
    }
    
    mutating func lerp(a: Vec2, b: Vec2, coef: Float32) {
        let result = a + (b - a) * coef
        
        x = result.x
        y = result.y
    }
}

func ==(lhs: Vec2, rhs: Vec2) -> Bool {
    return (lhs.x == rhs.x) && (lhs.y == rhs.y)
}

func * (lhs: Vec2, rhs: Float32) -> Vec2 {
    return Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
}

func * (lhs: Vec2, rhs: Vec2) -> Vec2 {    
    return Vec2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

func / (lhs: Vec2, rhs: Float32) -> Vec2 {
    return Vec2(x: lhs.x / rhs, y: lhs.y / rhs)
}

func / (lhs: Vec2, rhs: Vec2) -> Vec2 {
    return Vec2(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
}

func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
    return Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func - (lhs: Vec2, rhs: Vec2) -> Vec2 {
    return Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func + (lhs: Vec2, rhs: Float32) -> Vec2 {
    return Vec2(x: lhs.x + rhs, y: lhs.y + rhs)
}

func - (lhs: Vec2, rhs: Float32) -> Vec2 {
    return Vec2(x: lhs.x - rhs, y: lhs.y - rhs)
}

func += (lhs: inout Vec2, rhs: Vec2) {
    lhs = lhs + rhs
}

func -= (lhs: inout Vec2, rhs: Vec2) {
    lhs = lhs - rhs
}

func *= (lhs: inout Vec2, rhs: Vec2) {
    lhs = lhs * rhs
}

func /= (lhs: inout Vec2, rhs: Vec2) {
    lhs = lhs / rhs
}

