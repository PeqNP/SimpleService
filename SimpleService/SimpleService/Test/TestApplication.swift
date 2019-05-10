import Foundation
import UIKit

class TestApplication: UIApplication {
    
    private var appDelegate: UIApplicationDelegate?
    
    override init() {
        super.init()
        
        appDelegate = TestAppDelegate()
        delegate = appDelegate
    }
}
