/**
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import Nimble
import Quick

@testable import SimpleService

class URLRequestFactorySpec: QuickSpec {
    override func spec() {
        
        describe("URLRequestFactory") {
            var subject: URLRequestFactory!
            var urlRequest: URLRequest!

            beforeEach {
                urlRequest = nil
            }
            
            describe("POST; decoding strategy `.data`; PostBody is `Data`") {
                struct FakeEndpoint: ServiceEndpoint {
                    typealias ResponseType = Data
                    enum Header { }
                    enum PathParameter { }
                    enum QueryParameter { }
                    typealias PostBody = Data
                    
                    var type: ServiceRequestType = .post
                    var endpoints: Endpoints = [
                        .prod: "https://www.example.com/"
                    ]
                    var postBody: PostBody?
                    var httpBodyEncodingStrategy = HTTPBodyEncodingStrategy.data
                    
                    init(postBody: PostBody) {
                        self.postBody = postBody
                    }
                }

                beforeEach {
                    subject = URLRequestFactory()
                    let endpoint = FakeEndpoint(postBody: "Some data!".data(using: .utf8)!)
                    urlRequest = try? subject.make(from: endpoint, in: .prod)
                }
                
                it("should have encoded the data correctly") {
                    let httpBody = "Some data!".data(using: .utf8)!
                    expect(urlRequest.httpBody).to(equal(httpBody))
                }
            }
            
            describe("POST; decoding strategy `.json`; PostBody is `Data`") {
                struct FakeEndpoint: ServiceEndpoint {
                    typealias ResponseType = Data
                    enum Header { }
                    enum PathParameter { }
                    enum QueryParameter { }
                    typealias PostBody = Data
                    
                    var type: ServiceRequestType = .post
                    var endpoints: Endpoints = [
                        .prod: "https://www.example.com/"
                    ]
                    var postBody: PostBody?
                    var httpBodyEncodingStrategy = HTTPBodyEncodingStrategy.json
                    
                    init(postBody: PostBody) {
                        self.postBody = postBody
                    }
                }

                beforeEach {
                    subject = URLRequestFactory()
                    let endpoint = FakeEndpoint(postBody: "Some data!".data(using: .utf8)!)
                    urlRequest = try? subject.make(from: endpoint, in: .prod)
                }
                
                it("should have returned `nil`; not supported") {
                    expect(urlRequest.httpBody).to(beNil())
                }
            }

            describe("POST; decoding strategy `.json`; PostBody is `[String: Any]`") {
                struct FakeEndpoint: ServiceEndpoint {
                    typealias ResponseType = Data
                    enum Header { }
                    enum PathParameter { }
                    enum QueryParameter { }
                    enum PostParameter {
                        case username(String)
                    }
                    typealias PostBody = [PostParameter]
                    
                    var type: ServiceRequestType = .post
                    var endpoints: Endpoints = [
                        .prod: "https://www.example.com/"
                    ]
                    var postBody: PostBody?
                    var httpBodyEncodingStrategy = HTTPBodyEncodingStrategy.json
                    
                    init(postBody: PostBody?) {
                        self.postBody = postBody
                    }
                }
                
                beforeEach {
                    subject = URLRequestFactory()
                    let endpoint = FakeEndpoint(postBody: [.username("Eric")])
                    urlRequest = try? subject.make(from: endpoint, in: .prod)
                }
                
                it("should have encoded the data correctly") {
                    let httpBody: Data = ["username": "Eric"].asJson!
                    expect(urlRequest.httpBody).to(equal(httpBody))
                }
            }

            describe("POST; decoding strategy `.json`; PostBody is `Encodable`") {
                struct FakeEndpoint: ServiceEndpoint {
                    typealias ResponseType = Data
                    enum Header { }
                    enum PathParameter { }
                    enum QueryParameter { }
                    struct PostBody: Encodable {
                        let username: String
                    }
                    
                    var type: ServiceRequestType = .post
                    var endpoints: Endpoints = [
                        .prod: "https://www.example.com/"
                    ]
                    var postBody: PostBody
                    var httpBodyEncodingStrategy = HTTPBodyEncodingStrategy.json
                    
                    init(postBody: PostBody) {
                        self.postBody = postBody
                    }
                }
                
                beforeEach {
                    subject = URLRequestFactory()
                    let endpoint = FakeEndpoint(postBody: .init(username: "Eric"))
                    urlRequest = try? subject.make(from: endpoint, in: .prod)
                }
                
                fit("should have encoded the data correctly") {
                    let httpBody: Data = FakeEndpoint.PostBody(username: "Eric").asJson!
                    expect(urlRequest.httpBody).to(equal(httpBody))
                }
            }

            describe("POST; decoding strategy `.keyValuePair`; PostBody is `[String: Any]`") {
                struct FakeEndpoint: ServiceEndpoint {
                    typealias ResponseType = Data
                    enum Header { }
                    enum PathParameter { }
                    enum QueryParameter { }
                    enum PostBody {
                        case username(String)
                        case password(String)
                    }
                    
                    var type: ServiceRequestType = .post
                    var endpoints: Endpoints = [
                        .prod: "https://www.example.com/"
                    ]
                    var postBody: [PostBody]
                    var httpBodyEncodingStrategy = HTTPBodyEncodingStrategy.keyValue
                    
                    init(postBody: [PostBody]) {
                        self.postBody = postBody
                    }
                }

                beforeEach {
                    subject = URLRequestFactory()
                    let endpoint = FakeEndpoint(postBody: [.username("Eric"), .password("power9000")])
                    urlRequest = try? subject.make(from: endpoint, in: .prod)
                }
                
                it("should have encoded the data correctly") {
                    let httpBody = "username=Eric&password=power9000".data(using: .utf8)!
                    expect(urlRequest.httpBody).to(equal(httpBody))
                }
            }

        }
        
    }
}
