/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class URLRequestFactory {
    
    func make<T: ServiceEndpoint>(from request: T, in environment: Environment) throws -> URLRequest {
        guard let urlString = request.endpoints[environment] else {
            throw ServiceError.noURLForEnvironment(environment)
        }
        
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems(for: request)
        
        guard let url = urlComponents?.url else {
            throw ServiceError.invalidURLForEnvironment(environment)
        }
        
        return URLRequest(url: url)
    }
    
    private func queryItems<T: ServiceEndpoint>(for request: T) -> [URLQueryItem] {
        guard let params = request.queryParameters else {
            return []
        }
        
        return params.compactMap { (parameter) -> URLQueryItem? in
            let string = "\(parameter)"
            guard let range = string.range(of: "(") else {
                print("Failed to extract key/value GET parameter for \(parameter). It must be an `enum` case with a single associated value.")
                return nil
            }
            
            let name = string.prefix(upTo: range.lowerBound)
            
            let startIndex = string.index(after: range.lowerBound)
            let endIndex = string.index(before: string.endIndex)
            let valueSubstring = string[startIndex..<endIndex]
            let value = String(valueSubstring).replacingOccurrences(of: "\"", with: "")
            
            return URLQueryItem(name: String(name), value: value)
        }
    }
}
