//
//  Service.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation

class Service {
    internal func decode<T: Decodable>(type: T.Type, data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    internal func encode<T: Encodable>(object: T) throws -> Encodable {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(object)
    }
    
    func completeError(_ data: Data, _ completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        do {
            let err = try self.decode(type: ErrorResponse.self, data: data)
            completion(.failure(err))
        } catch {
            completion(.failure(error))
        }
    }
}
