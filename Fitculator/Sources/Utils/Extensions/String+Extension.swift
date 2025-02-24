import SwiftUI

extension String {
    var localized: String {
        let languageCode = UserDefaults.standard.string(forKey: "languageCode") ?? "en"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : Bundle.main
        return NSLocalizedString(self, tableName: nil, bundle: bundle ?? Bundle.main, value: "", comment: "")
    }
}
