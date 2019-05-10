import Foundation
import UIKit

class Application: UIApplication {
    
    var appDelegate: UIApplicationDelegate?
    
    override init() {
        super.init()
        
        appDelegate = AppDelegate()
        delegate = appDelegate
    }
}
