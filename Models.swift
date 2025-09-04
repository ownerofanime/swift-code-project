import Foundation

struct ScannableReceiptItem: Codable, Hashable, Identifiable { var id:Int; var name:String; var price:Double; var quantity:Int }
struct ScannableReceipt: Codable, Identifiable {
    var id:String; var merchant_name:String; var merchant_address:String?; var items:[ScannableReceiptItem]
    var subtotal:Double; var tax:Double; var total:Double; var payment_method:String
    var date:String; var time:String; var currency:String
}
struct ReceiptClaim: Codable { let rid:String; let merchant_name:String; let date:String; let time:String; let total:Double; let currency:String; let sig:String }
