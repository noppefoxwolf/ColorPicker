import UIKit

public protocol ColorPicker: AnyObject {
    var id: String { get }
    var title: String { get }
    var color: HSVA { get set }
    var continuously: Bool { get }
}
