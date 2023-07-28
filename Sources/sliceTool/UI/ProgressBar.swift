import Foundation

final class ProgressBar {
    private let width: Int = 42
    var count: Int = 0 {
        didSet {
            display()
        }
    }
    var filled: Int = 0 {
        didSet {
            display()
        }
    }

    func display() {
        let f = count > 0 ? width * filled / count : 0
        print("\u{1B}[A\u{1B}[K" + String(repeating: "▰", count: f) + String(repeating: "▱", count: width - f) + " slice \(filled) of \(count)")
    }
}
