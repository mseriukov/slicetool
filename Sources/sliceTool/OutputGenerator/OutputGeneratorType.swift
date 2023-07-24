import Foundation
import VectorMath

protocol OutputGeneratorType {
    func generate(polylines: [Polyline2], gmin: Vector2, gmax: Vector2) -> Data?
}

enum OutputGenerator { }
