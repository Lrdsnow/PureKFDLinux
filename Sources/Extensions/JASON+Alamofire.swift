//
//  Featured.swift
//  purekfd
//
//  Created by Lrdsnow on 6/27/24.
//  Originally from https://github.com/delba/JASON/blob/master/Extensions/JASON+Alamofire.swift but rewritten to work with Alamofire 5
//
// im just checking for Combine bcuz its a private framework as is a pretty good indicator of running on an apple system or not
//

import Foundation
import Alamofire

#if canImport(Combine)
import JASON
#else
@preconcurrency
import JASON
#endif

struct JASONResponseSerializer: DataResponseSerializerProtocol {
    typealias SerializedObject = JASON.JSON

    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> JASON.JSON {
        if let error = error {
            throw AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error))
        }

        guard let validData = data else {
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }

        return JASON.JSON(validData)
    }
}

#if canImport(Combine)
extension DataRequest {
    @discardableResult
    public func responseJASON(queue: DispatchQueue = .main, completionHandler: @escaping (AFDataResponse<JASON.JSON>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: JASONResponseSerializer(), completionHandler: completionHandler)
    }
}
#else
extension DataRequest {
    @discardableResult
    public func responseJASON(queue: DispatchQueue = .main, completionHandler: @Sendable @escaping (AFDataResponse<JASON.JSON>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: JASONResponseSerializer(), completionHandler: completionHandler)
    }
}
#endif