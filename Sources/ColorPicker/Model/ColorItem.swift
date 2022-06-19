import UIKit

public struct ColorItem: Hashable {
    public init(id: UUID, color: CGColor) {
        self.id = id
        self.color = color
    }
    
    public var id: UUID
    public var color: CGColor
}
