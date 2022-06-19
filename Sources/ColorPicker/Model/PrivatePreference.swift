import Foundation

extension UserDefaults {
    var latestColorPickerID: String? {
        get { self.string(forKey: #function) }
        set { self.set(newValue, forKey: #function) }
    }
}
