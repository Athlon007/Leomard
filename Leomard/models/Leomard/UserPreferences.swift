//
//  UserPreferences.swift
//  Leomard
//
//  Created by Konrad Figura on 08/07/2023.
//

import Foundation
import SwiftUI

final class UserPreferences: ObservableObject {
    @AppStorage("show_nsfw", store: .standard) var showNsfw: Bool = false
    @AppStorage("blur_nsfw", store: .standard) var blurNsfw: Bool = true
}
