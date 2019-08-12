import Foundation

protocol SlicerType {
    func slice(mesh: Mesh, z: Float) -> [[Vec2]]
}

