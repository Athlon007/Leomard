//
//  ModAdd.swift
//  Leomard
//
//  Created by Konrad Figura on 03/08/2023.
//

import Foundation

struct ModAdd: Codable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let removed: Bool
    let when_: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.modPersonId = try container.decode(Int.self, forKey: .modPersonId)
        self.otherPersonId = try container.decode(Int.self, forKey: .otherPersonId)
        self.removed = try container.decode(Bool.self, forKey: .removed)
        
        let dateString = try container.decode(String.self, forKey: .when_)
        self.when_ = try DateFormatConverter.formatToDate(from: dateString)
    }
}
