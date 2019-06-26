/**
 A simple logging service.
 
 Please feel free to remove this. I use this as a way to send events to logging services, debugging, and sometimes as analytics.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration, Inc. All rights reserved.
 */

import Foundation

enum LogLevel: Int {
    case info
    case warning
    case error
    case critical
    
    public static func < (a: LogLevel, b: LogLevel) -> Bool {
        return a.rawValue < b.rawValue
    }
}

var log = Logger()

class Logger {
    
    var level: LogLevel = .info
    
    func i(_ message: String) {
        guard level < .warning else {
            return
        }
        print("INFO: \(message)")
    }
    
    func w(_ message: String) {
        guard level < .error else {
            return
        }
        print("WARN: \(message)")
    }
    
    func e(_ message: String) {
        guard level < .critical else {
            return
        }
        print("ERROR: \(message)")
    }
    func e(_ error: Error) {
        guard level < .critical else {
            return
        }
        print("ERROR: \(error)")
    }
    
    func c(_ message: String) {
        print("CRITICAL: \(message)")
    }
}
