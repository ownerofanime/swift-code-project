import Foundation

final class ReceiptService {
    static let shared = ReceiptService()
    // CHANGE to your Mac LAN IP when running on device
    private let baseURL = URL(string: "http://localhost:8080")!
    func fetchReceipt(id:String, sig:String?, completion:@escaping(Result<ScannableReceipt,Error>)->Void) {
        var comps = URLComponents(url: baseURL.appendingPathComponent("/api/receipts/\(id)"), resolvingAgainstBaseURL: false)!
        if let sig = sig { comps.queryItems = [URLQueryItem(name: "sig", value: sig)] }
        let url = comps.url!
        URLSession.shared.dataTask(with: url) { data, _, err in
            if let err = err { return completion(.failure(err)) }
            guard let data = data else { return completion(.failure(NSError(domain:"",code:-1))) }
            do { let rec = try JSONDecoder().decode(ScannableReceipt.self, from: data); completion(.success(rec)) }
            catch { completion(.failure(error)) }
        }.resume()
    }
    func list(completion:@escaping(Result<[ScannableReceipt],Error>)->Void) {
        let url = baseURL.appendingPathComponent("/api/receipts")
        URLSession.shared.dataTask(with: url) { data, _, err in
            if let err = err { return completion(.failure(err)) }
            guard let data = data else { return completion(.failure(NSError(domain:"",code:-1))) }
            do { completion(.success(try JSONDecoder().decode([ScannableReceipt].self, from: data))) }
            catch { completion(.failure(error)) }
        }.resume()
    }
}
