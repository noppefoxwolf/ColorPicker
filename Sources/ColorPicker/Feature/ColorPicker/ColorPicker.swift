import UIKit

public protocol ColorPicker: AnyObject {
    var id: String { get }
    var title: String { get }
    var color: UIColor { get set }
    var continuously: Bool { get }
}
