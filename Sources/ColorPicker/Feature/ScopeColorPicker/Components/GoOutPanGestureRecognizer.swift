import UIKit

/// Viewの外に出た時に初めてbeganになるPanジェスチャ
public class GoOutPanGestureRecognizer: UIPanGestureRecognizer {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if state == .possible {
            let location = touches.first!.location(in: view)
            if !view!.bounds.contains(location) {
                super.touchesBegan(touches, with: event)
                super.touchesMoved(touches, with: event)
            }
        } else {
            super.touchesMoved(touches, with: event)
        }
    }
}
