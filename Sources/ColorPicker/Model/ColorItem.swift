import UIKit

public struct ColorItem: Hashable {
    public init(id: UUID, color: UIColor) {
        self.id = id
        self.color = color
    }
    
    public var id: UUID
    public var color: UIColor
}
