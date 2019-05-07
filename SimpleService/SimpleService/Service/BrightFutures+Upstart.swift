/**
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation
import BrightFutures

extension Promise {
    func reduce<V>(_ initial: T, _ collection: [V], reducer: @escaping (T, V) -> Future<T, E>) -> Future<T, E> {
        SimpleService.reduce(self, initial, collection, reducer: reducer)
        return future
    }
}

private func reduce<T, E: Error, V>(_ promise: Promise<T, E>, _ initial: T, _ collection: [V], reducer: @escaping (T, V) -> Future<T, E>) {
    guard collection.count > 0 else {
        return promise.success(initial)
    }
    
    var collection = collection
    let value = collection.removeFirst()
    reducer(initial, value)
        .onSuccess { (value) in
            reduce(promise, value, collection, reducer: reducer)
        }
        .onFailure { (error) in
            promise.failure(error)
        }
}
