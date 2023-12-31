//
//  URL.swift
//  Leomard
//
//  Created by Konrad Figura on 10/07/2023.
//

import Foundation

extension URL {
    // Source: https://stackoverflow.com/questions/65224939/how-to-check-if-a-url-is-valid-in-swift
    func isReachable(completion: @escaping (Bool) -> ()) {
        if (self.absoluteString.range(of: "(https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|www\\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9]+\\.[^\\s]{2,}|www\\.[a-zA-Z0-9]+\\.[^\\s]{2,})", options: .regularExpression, range: nil, locale: nil) == nil) {
            completion(false)
        }
        
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            let r = (response as? HTTPURLResponse)
            
            if r?.statusCode == 405 {
                // Server does not allow "HEAD" for whatever reason?
                // Try sending full on "GET" request instead.
                URLSession.shared.dataTask(with: URLRequest(url: self)) { _, response2, _ in
                    let r2 = (response2 as? HTTPURLResponse)
                    completion(r2?.statusCode == 200)
                }
            } else {
                completion(r?.statusCode == 200)
            }
        }.resume()
    }
}
