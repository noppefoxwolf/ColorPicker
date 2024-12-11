import UIKit

public struct ColorItem: Hashable, Sendable {
    public init(id: UUID, color: HSVA) {
        self.id = id
        self.color = color
    }
    
    public var id: UUID
    public var color: HSVA
}
