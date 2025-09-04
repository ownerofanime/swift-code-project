import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let payload: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    var body: some View {
        if let ui = generate() {
            Image(uiImage: ui).interpolation(.none).resizable().scaledToFit().frame(width: 240, height: 240)
        } else { Color.gray.frame(width: 240, height: 240) }
    }
    private func generate() -> UIImage? {
        let data = Data(payload.utf8)
        filter.setValue(data, forKey: "inputMessage")
        guard let out = filter.outputImage else { return nil }
        let scaled = out.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        if let cg = CIContext().createCGImage(scaled, from: scaled.extent) { return UIImage(cgImage: cg) }
        return nil
    }
}
