/**
 Provides ability to make requests.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum ServiceError: Error {
    case unknown(Error?)
    case noURLForEnvironment(Environment)
    case invalidURLForEnvironment(Environment)
    case emptyResponse
    case failedToDecode
    case noInternetConnection
    case server(Error)
}

struct ServiceResult {
    var data: Data?
    var error: Error?
}

class Service {
    let environment: Environment
    let requester: ServiceRequester
    let plugins: [ServicePlugin]
    
    let urlRequestFactory = URLRequestFactory()
    let decoder = JSONDecoder()
    
    init(environment: Environment, requester: ServiceRequester, plugins: [ServicePlugin]) {
        self.environment = environment
        self.requester = requester
        self.plugins = plugins
    }
    
    func request<T: ServiceEndpoint>(_ request: T) -> Future<T.ResponseType, ServiceError> {
        var urlRequest: URLRequest
        do {
            urlRequest = try urlRequestFactory.make(from: request, in: environment)
        }
        catch let error as ServiceError {
            return Future(error: error)
        }
        catch {
            return Future(error: .unknown(error))
        }

        urlRequest = plugins.reduce(urlRequest, { (urlRequest, plugin) -> URLRequest in
            return plugin.willSendRequest(urlRequest)
        })
        
        let promise = Promise<T.ResponseType, ServiceError>()
        
        requester.request(urlRequest) { [weak self] (result) in
            guard let self = self else {
                promise.failure(.unknown(nil))
                return
            }
            
            let result = self.plugins.reduce(result, { (response, plugin) -> ServiceResult in
                return plugin.didReceiveResponse(response)
            })
            
            if let error = result.error as? URLError {
                switch error.code.rawValue {
                case -1009:
                    promise.failure(.noInternetConnection)
                default:
                    promise.failure(.server(error))
                }
                return
            }
            else if let error = result.error as? ServiceError {
                promise.failure(error)
                return
            }
            else if let error = result.error {
                promise.failure(.unknown(error))
                return
            }
            
            guard let data = result.data else {
                promise.failure(.emptyResponse)
                return
            }
            guard let decodedResponse = try? self.decoder.decode(T.ResponseType.self, from: data) else {
                promise.failure(.failedToDecode)
                return
            }
            
            promise.success(decodedResponse)
        }
        
        plugins.forEach { (plugin) in
            plugin.didSendRequest(urlRequest)
        }
        
        return promise.future
    }
}
