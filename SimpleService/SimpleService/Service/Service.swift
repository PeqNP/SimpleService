/**
 Provides ability to make requests.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum ServiceError: Error {
    case strongSelf
    case unknown(Error?)
    case noURLForEnvironment(Environment)
    case invalidURLForEnvironment(Environment)
    case emptyResponse
    case failedToDecode
    case noInternetConnection
    case server(Error)
    case requiredPluginsNotFound([ServicePluginKey])
    case pluginError(ServicePluginError)
}

struct ServiceResult {
    var statusCode: Int?
    var data: Data?
    var error: Error?
}

class Service {
    
    /// Will print the `URLRequest`
    var debug: Bool = false
    
    /// NOTE: Must use `var` for now to remove circular dependency.
    var pluginProvider: ServicePluginProvider?
    
    private let environment: Environment
    private let requester: ServiceRequester
    
    private let urlRequestFactory = URLRequestFactory()
    private let decoder = JSONDecoder()
    
    init(environment: Environment, requester: ServiceRequester/*, pluginProvider: ServicePluginProvider*/) {
        self.environment = environment
        self.requester = requester
//        self.pluginProvider = pluginProvider
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
        
        let plugins: [ServicePlugin]
        do {
            plugins = try pluginProvider?.pluginsFor(endpoint) ?? [ServicePlugin]()
        }
        catch let error as ServiceError {
            return Future(error: error)
        }
        catch {
            return Future(error: .unknown(error))
        }
        
        let promise = Promise<T.ResponseType, ServiceError>()
        
        DispatchQueue.main.async { [weak self] in
            self?.request(endpoint, urlRequest, with: plugins, promise: promise)
        }
        
        return promise.future
    }
    
    func request<T: ServiceEndpoint>(_ endpoint: T, _ urlRequest: URLRequest, with plugins: [ServicePlugin], promise: Promise<T.ResponseType, ServiceError>) {
        
        var sendPromise: Promise<URLRequest, ServicePluginError>?
        var resultPromise: Promise<ServiceResult, ServicePluginError>?
        
        func handleRequest() {
            sendPromise = Promise<URLRequest, ServicePluginError>()
            sendPromise?.reduce(urlRequest, plugins) { (urlRequest, plugin) -> Future<URLRequest, ServicePluginError> in
                return plugin.willSendRequest(urlRequest)
                }
                .onSuccess { [weak self] (urlRequest) in
                    guard let sself = self else {
                        return promise.failure(.strongSelf)
                    }
                    
                    if sself.debug {
                        printRequest(urlRequest)
                    }
                    
                    sself.requester.request(urlRequest) { [weak self] (result) in
                        resultPromise = Promise<ServiceResult, ServicePluginError>()
                        resultPromise?.reduce(result, plugins) { (result, plugin) in
                            return plugin.didReceiveResponse(result)
                            }
                            .onFailure { (error) in
                                guard error == .retryRequest else {
                                    return promise.failure(.pluginError(error))
                                }
                                handleRequest()
                            }
                            .onSuccess { [weak self] (result) in
                                guard let decoder = self?.decoder else {
                                    return promise.failure(.strongSelf)
                                }
                                
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
                                    return promise.failure(error)
                                }
                                else if let error = result.error {
                                    return promise.failure(.unknown(error))
                                }
                                
                                guard let data = result.data else {
                                    return promise.failure(.emptyResponse)
                                }
                                // Return the raw data of the response. This is usually used during testing.
                                if let data = data as? T.ResponseType, data is Data {
                                    return promise.success(data)
                                }
                                guard let decodedResponse = try? decoder.decode(T.ResponseType.self, from: data) else {
                                    return promise.failure(.failedToDecode)
                                }
                                
                                promise.success(decodedResponse)
                        }
                    }
                    
                    plugins.forEach { (plugin) in
                        plugin.didSendRequest(urlRequest)
                    }
            }
        }
        handleRequest()
    }
}

// MARK: - Request Debug Tools

func prettyPrint(_ data: Data) {
    guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
        let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
        let prettyPrintedString = String(data: data, encoding: .utf8) else {
            log.e("Failed to pretty print Data!")
            return
    }
    
    print(prettyPrintedString)
}

enum HTTPBodyDataType {
    case string
    case image
    case data
}

func printRequest(_ request: URLRequest, encoding: HTTPBodyDataType = .string) {
    guard let url = request.url else {
        return log.e("Could not get URL")
    }
    log.i("\(request.httpMethod?.uppercased() ?? "UK") \(url)")
    if let headers = request.allHTTPHeaderFields {
        log.i("Headers:")
        headers.forEach { (tuple) in
            log.i("  \(tuple.key): \(tuple.value)")
        }
    }
    if let httpBody = request.httpBody {
        log.i("Body:")
        switch encoding {
        case .string:
            log.i(String(data: httpBody, encoding: .utf8) ?? "  Unknown HTTP Body Encoding")
        case .image:
            log.i("  Image data w/ \(httpBody.count) byte(s)")
        case .data:
            log.i("  Data w/ \(httpBody.count) byte(s)")
        }
    }
}
