/**
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

protocol LoginProvider {
    func login(username: String, password: String) -> Future<LoginResponse, LoginServiceError>
}
