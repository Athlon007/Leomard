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
    
    func respond<T: Decodable>(_ result: Result<APIResponse, Error>, _ completion: @escaping (Result<T, Error>) -> Void) {
        switch result {
        case .success(let apiResponse):
            if let data = apiResponse.data {
                do {
                    let response = try self.decode(type: T.self, data: data)
                    completion(.success(response))
                } catch {
                    self.respondError(data, completion)
                }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func respondError<T: Decodable>(_ data: Data, _ completion: @escaping (Result<T, Error>) -> Void) {
        do {
            let err = try self.decode(type: ErrorResponse.self, data: data)
            completion(.failure(err))
        } catch {
            completion(.failure(error))
        }
    }
}
