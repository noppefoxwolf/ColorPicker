import UIKit

public protocol ColorPicker: AnyObject {
    var title: String { get }
    var color: UIColor { get set }
    var continuously: Bool { get }
}
