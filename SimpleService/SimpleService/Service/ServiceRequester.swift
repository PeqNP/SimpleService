import Foundation

protocol ServiceRequester {
    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void)
}
