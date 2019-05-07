import BrightFutures
import Foundation
import Nimble

extension Future {
    func waitUntilCompleted() {
        expect(self.isCompleted).toEventually(beTrue())
    }
}
