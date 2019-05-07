/**
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import AutoEquatable
import BrightFutures
import Foundation
import Nimble
import Quick
import Spry

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

extension Future {
    func waitUntilCompleted() {
        expect(self.isCompleted).toEventually(beTrue())
    }
}

extension LoginResponse: AutoEquatable { }

class LoginServiceSpec: QuickSpec {
    override func spec() {
        
        describe("LoginService") {
            var subject: LoginService!
            var requester: FakeServiceRequester!
            var pluginProvider: FakeServicePluginProvider!
            
            beforeEach {
                requester = FakeServiceRequester()
                pluginProvider = FakeServicePluginProvider()
                subject = LoginService(environment: .prod, requester: requester, pluginProvider: pluginProvider)
            }
            
            describe("login") {
                var future: Future<LoginResponse, LoginServiceError>!
                
                beforeEach {
                    future = subject.login(username: "username", password: "password")
                    future.waitUntilCompleted()
                }
                
                it("should have returned a response") {
                    expect(future.value).to(equal(LoginResponse(firstName: "Eric", lastName: "Chamberlain")))
                }
            }
        }
        
    }
}
