import Foundation
import UIKit

func applicationClassName() -> String? {
    if NSClassFromString("XCTestCase") == nil {
        return NSStringFromClass(Application.self)
    }
    else {
        return NSStringFromClass(TestApplication.self)
    }
}

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, applicationClassName(), nil)
