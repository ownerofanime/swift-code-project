import SwiftUI

struct MerchantRootView: View {
    @State private var form = MerchantReceipt(
        id: nil,
        merchant_name: "7-Eleven Orchard",
        merchant_address: "123 Orchard Road, Singapore",
        items: [
            MerchantItem(name: "Coffee", price: 3.50, quantity: 1),
            MerchantItem(name: "Sandwich", price: 8.90, quantity: 1)
        ],
        payment_method: "Cash",
        date: ISO8601DateFormatter().string(from: Date()).prefix(10).description,
        time: "14:30:00",
        currency: "SGD"
    )
    @State private var claim: ReceiptClaim?
    @State private var errorText: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Merchant")) {
                    TextField("Name", text: $form.merchant_name)
                    TextField("Address", text: Binding($form.merchant_address, replacingNilWith: ""))
                    Picker("Payment", selection: $form.payment_method) {
                        Text("Cash").tag("Cash"); Text("Card").tag("Card"); Text("PayNow").tag("PayNow"); Text("GrabPay").tag("GrabPay")
                    }
                }
                Section(header: Text("Datetime")) {
                    TextField("Date (YYYY-MM-DD)", text: $form.date)
                    TextField("Time (HH:mm:ss)", text: $form.time)
                }
                Section(header: Text("Items")) {
                    ForEach($form.items) { $item in
                        HStack {
                            TextField("Name", text: $item.name)
                            TextField("Price", value: $item.price, format: .number).keyboardType(.decimalPad).frame(width: 80)
                            TextField("Qty", value: $item.quantity, format: .number).keyboardType(.numberPad).frame(width: 50)
                        }
                    }
                    Button("+ Add Item") { form.items.append(MerchantItem(name: "", price: 0, quantity: 1)) }
                }
                Button("Generate QR") { create() }
                if let err = errorText { Text(err).foregroundColor(.red) }
                if let c = claim, let data = try? JSONEncoder().encode(c), let json = String(data: data, encoding: .utf8) {
                    Section(header: Text("Show this QR to customer")) {
                        HStack { Spacer(); QRCodeView(payload: json); Spacer() }
                    }
                }
            }.navigationTitle("EcoMerchant")
        }
    }
    private func create() {
        ReceiptService.shared.create(form) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let resp): self.claim = resp.claim; self.errorText = nil
                case .failure(let e): self.errorText = e.localizedDescription
                }
            }
        }
    }
}

extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith replacement: String) {
        self.init(get: { source.wrappedValue ?? replacement }, set: { source.wrappedValue = $0 })
    }
}
