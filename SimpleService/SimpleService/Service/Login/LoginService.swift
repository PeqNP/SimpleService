/**
 A fake login service that shows how to consume a `LoginServiceEndpoint` which is configured with every possible property of a `ServiceEndpoint`.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

class LoginService: LoginProvider {
    
    let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    func login(username: String, password: String) -> Future<User, LoginProviderError> {
        let endpoint = LoginEndpoint(
            headers: [
                .secret_key("super-secret-hash" /* dependency may provide this value or is injected from a `ServicePlugin` */)
            ],
            pathParameters: [
                .version("1.1"),
                .sessionid("my-session-id" /* dependency may provide this value or is injected from a `ServicePlugin` */)
            ],
            queryParameters: [
                .format("json")
            ],
            postBody: [
                .username(username),
                .password(password)
            ]
        )
        return service.request(endpoint)
            .map { response -> User in
                return User(firstName: response.firstName, lastName: response.lastName)
            }
            .mapError { (error) -> LoginProviderError in
                return .unknown(error)
            }
    }
    
    /// func logout
}
