import BrightFutures
import Foundation

/// Provides a way for a response to signal that the request was a success but to ignore the value.
struct IgnorableValue { }
struct NoError: Error { }

protocol ServiceRequester {
    func initialized<T: ServiceEndpoint>(_ endpoint: T) -> Future<IgnorableValue, NoError>
    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void)
}
