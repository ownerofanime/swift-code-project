import SwiftUI
import SafariServices

struct WalletRootView: View {
    @State private var scanned: ScannableReceipt?
    @State private var errorText: String?
    @State private var showPDF: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text("Scan Receipt").font(.title2).bold()
                QRScannerView { text in handle(text) }
                    .frame(height: 320).clipShape(RoundedRectangle(cornerRadius: 12))
                
                if let r = scanned {
                    List(r.items, id: \.id) { it in
                        HStack {
                            Text(it.name)
                            Spacer()
                            Text("x\(it.quantity)")
                            Text(String(format: "$%.2f", it.price))
                        }
                    }.frame(height: 220)
                    VStack(alignment: .trailing) {
                        Text(String(format: "Subtotal: %.2f %@", r.subtotal, r.currency))
                        Text(String(format: "GST (9%%): %.2f %@", r.tax, r.currency))
                        Text(String(format: "Total: %.2f %@", r.total, r.currency)).bold()
                    }
                    Button("Open PDF") {
                        if let url = URL(string: "http://localhost:8080/api/receipts/\(r.id)/pdf") {
                            showPDF = url
                        }
                    }.buttonStyle(.borderedProminent)
                }
                
                if let e = errorText { Text(e).foregroundColor(.red) }
                
                Spacer()
            }
            .padding()
            .navigationTitle("EcoWallet")
        }
        .sheet(item: $showPDF) { url in
            SafariView(url: url)
        }
    }
    
    private func handle(_ text: String) {
        guard let data = text.data(using: .utf8), let claim = try? JSONDecoder().decode(ReceiptClaim.self, from: data) else {
            errorText = "Invalid QR"; return
        }
        ReceiptService.shared.fetchReceipt(id: claim.rid, sig: claim.sig) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let r): self.scanned = r; self.errorText = nil
                case .failure(let e): self.errorText = e.localizedDescription
                }
            }
        }
    }
}

struct SafariView: UIViewControllerRepresentable, Identifiable {
    let id = UUID(); let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
