import Spry
import Foundation

@testable import SimpleService

class FakeServicePluginProvider: ServicePluginProvider, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case none
    }
    
    enum Function: String, StringRepresentable {
        case registerPlugin = "registerPlugin(_:)"
        case registerPlugins = "registerPlugins(_:)"
    }
    
    override func registerPlugin(_ plugin: ServicePlugin) {
        return spryify(arguments: plugin)
    }
    
    override func registerPlugins(_ plugins: [ServicePlugin]) {
        return spryify(arguments: plugins)
    }
}
