import SwiftUI

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
