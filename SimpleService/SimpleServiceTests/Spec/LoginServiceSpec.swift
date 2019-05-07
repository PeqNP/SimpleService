/**
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation
import Nimble
import Quick
import Spry
import Spry_Nimble

@testable import SimpleService

class LoginServiceSpec: QuickSpec {
    override func spec() {
        
        describe("LoginService") {
            var subject: LoginService!
            var service: FakeService!
            
            beforeEach {
                service = FakeService()
                subject = LoginService(service: service)
            }
            
            describe("login") {
                var future: Future<User, LoginProviderError>!
                
                beforeEach {
                    let response = LoginEndpoint.ResponseType(firstName: "Eric", lastName: "Chamberlain", rewardsLevel: 1, lastLogin: Date())
                    service.stub(.request).andReturn(Future<LoginEndpoint.ResponseType, ServiceError>(value: response))
                    future = subject.login(username: "username", password: "password")
                }
                
                it("should have made the correct request") {
                    let expectedEndpoint = LoginEndpoint(
                        headers: [
                            .secret_key("super-secret-hash")
                        ],
                        pathParameters: [
                            .version("1.1"),
                            .sessionid("my-session-id")
                        ],
                        queryParameters: [
                            .format("json")
                        ],
                        postParameters: [
                            .username("username"),
                            .password("password")
                        ]
                    )
                    expect(service).to(haveReceived(.request, with: expectedEndpoint))
                }
                
                it("should have returned the correct response") {
                    let expecetedUser = User(firstName: "Eric", lastName: "Chamberlain")
                    expect(future.value).toEventually(equal(expecetedUser))
                }
            }
        }
        
    }
}
