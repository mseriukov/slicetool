import Foundation
import VectorMath

protocol OutputGeneratorType {
    func generate(polygons: [[Vector2]], gmin: Vector2, gmax: Vector2) -> Data?
}

enum OutputGenerator { }
