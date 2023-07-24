import Foundation
import VectorMath

protocol SlicerType {
    func slice(mesh: Mesh, z: Float) -> [Polyline2]
}

