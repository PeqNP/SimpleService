import Spry
import Foundation

@testable import SimpleService

class FakeServiceRequester: ServiceRequester, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case none
    }
    
    enum Function: String, StringRepresentable {
        case request = "request(_:callback:)"
    }
    
    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void) {
        return spryify(arguments: urlRequest, callback)
    }
}
