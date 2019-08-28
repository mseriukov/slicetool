import Foundation
import VectorMath

class STLParser {

    func floatValue(data: Data) -> Float32 {
        return Float32(bitPattern: data.withUnsafeBytes { $0.load(as: UInt32.self) }.bigEndian)
    }

    func parseSTL(_ url: URL) -> Mesh? {
        guard let stream: InputStream = InputStream(fileAtPath: url.path) else { return nil }
        stream.open()
        defer {
            stream.close()
        }

        var headerBuf:[UInt8] = [UInt8](repeating: 0, count: 80)
        let headerLen = stream.read(&headerBuf, maxLength: headerBuf.count)

        guard headerLen == 80 else { return nil }

        var countBuf:[UInt8] = [UInt8](repeating: 0, count: 4)
        let countLen = stream.read(&countBuf, maxLength: countBuf.count)

        guard countLen == 4 else { return nil }

        let cntData = Data([countBuf[3], countBuf[2], countBuf[1], countBuf[0]])
        let _ = cntData.withUnsafeBytes { $0.load(as: UInt32.self) }.bigEndian

        let result: Mesh = Mesh()
        var buf: [UInt8] = [UInt8](repeating: 0, count: 12*4+2)
        while true {
            let len = stream.read(&buf, maxLength: buf.count)

            if len < buf.count {
                break
            }

            var offset: Int = 0
            let n = Vector3(
                floatValue(data: Data([buf[offset+3], buf[offset+2], buf[offset+1], buf[offset+0]])),
                floatValue(data: Data([buf[offset+7], buf[offset+6], buf[offset+5], buf[offset+4]])),
                floatValue(data: Data([buf[offset+11], buf[offset+10], buf[offset+9], buf[offset+8]]))
            )
            offset += 12

            let v1 = Vertex(position: Vector3(
                floatValue(data: Data([buf[offset+3], buf[offset+2], buf[offset+1], buf[offset+0]])),
                floatValue(data: Data([buf[offset+7], buf[offset+6], buf[offset+5], buf[offset+4]])),
                floatValue(data: Data([buf[offset+11], buf[offset+10], buf[offset+9], buf[offset+8]]))
            ))
            offset += 12

            let v2 = Vertex(position: Vector3(
                floatValue(data: Data([buf[offset+3], buf[offset+2], buf[offset+1], buf[offset+0]])),
                floatValue(data: Data([buf[offset+7], buf[offset+6], buf[offset+5], buf[offset+4]])),
                floatValue(data: Data([buf[offset+11], buf[offset+10], buf[offset+9], buf[offset+8]]))
            ))
            offset += 12

            let v3 = Vertex(position: Vector3(
                floatValue(data: Data([buf[offset+3], buf[offset+2], buf[offset+1], buf[offset+0]])),
                floatValue(data: Data([buf[offset+7], buf[offset+6], buf[offset+5], buf[offset+4]])),
                floatValue(data: Data([buf[offset+11], buf[offset+10], buf[offset+9], buf[offset+8]]))
            ))
            offset += 12

            result.addTriangle(Triangle(v1: v1, v2: v2, v3: v3, n: n))

            let attrData = Data([buf[offset+0], buf[offset+1]])
            let _ = attrData.withUnsafeBytes { $0.load(as: UInt16.self) }.bigEndian
        }
        return result
    }

}
