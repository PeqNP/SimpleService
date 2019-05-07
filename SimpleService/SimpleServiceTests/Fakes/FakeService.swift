import BrightFutures
import Foundation
import Spry

@testable import SimpleService

class FakeService: Service, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case none
    }
    
    enum Function: String, StringRepresentable {
        case request = "request(_:)"
    }

    init() {
        super.init(environment: .prod, requester: FakeServiceRequester())
    }
    
    override func request<T>(_ endpoint: T) -> Future<T.ResponseType, ServiceError> where T : ServiceEndpoint {
        return spryify(arguments: endpoint)
    }
}
