import Foundation
import UIKit
import MobileCoreServices

@objcMembers class SecureClipboard: NSObject {
    static func setClipboardItem(_ value: String) {
        let pasteboardItems = [[
            kUTTypePlainText as String: value
        ]]
        let pasteboardOptions : [UIPasteboard.OptionsKey: Any] = [
            UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 2),
            UIPasteboard.OptionsKey.localOnly: true
        ]
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
    }
}
