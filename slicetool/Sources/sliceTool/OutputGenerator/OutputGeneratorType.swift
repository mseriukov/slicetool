import Foundation

protocol OutputGeneratorType {
    func generate(polygons: [[Vec2]], gmin: Vec2, gmax: Vec2) -> Data?
}

enum OutputGenerator { }
