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
    
    private static var plugins: [ServicePlugin] = []
    
    static func registerPlugin(_ plugin: ServicePlugin) {
        // TODO
    }
    
    static func registerPlugins(_ plugins: [ServicePlugin]) {
        // TODO
    }
    
    let environment: Environment
    let requester: ServiceRequester
    
    let urlRequestFactory = URLRequestFactory()
    let decoder = JSONDecoder()
    
    init(environment: Environment, requester: ServiceRequester) {
        self.environment = environment
        self.requester = requester
    }
    
    func request<T: ServiceEndpoint>(_ endpoint: T) -> Future<T.ResponseType, ServiceError> {
        var urlRequest: URLRequest
        do {
            urlRequest = try urlRequestFactory.make(from: endpoint, in: environment)
        }
        catch let error as ServiceError {
            return Future(error: error)
        }
        catch {
            return Future(error: .unknown(error))
        }

        urlRequest = pluginsFor(endpoint).reduce(urlRequest, { (urlRequest, plugin) -> URLRequest in
            return plugin.willSendRequest(urlRequest)
        })
        
        let promise = Promise<T.ResponseType, ServiceError>()
        
        requester.request(urlRequest) { [weak self] (result) in
            guard let self = self else {
                promise.failure(.unknown(nil))
                return
            }
            
            let result = self.pluginsFor(endpoint).reduce(result, { (response, plugin) -> ServiceResult in
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
        
        pluginsFor(endpoint).forEach { (plugin) in
            plugin.didSendRequest(urlRequest)
        }
        
        return promise.future
    }
    
    private func pluginsFor<T: ServiceEndpoint>(_ endpoint: T) -> [ServicePlugin] {
        // Filter registerd plugins
        // Emit when plugin not found
        return []
    }
}
