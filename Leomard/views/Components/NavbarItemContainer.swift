//
//  NavbarItemContainer.swift
//  Leomard
//
//  Created by Konrad Figura on 02/07/2023.
//

import Foundation
import SwiftUI

extension VStack {
    func NavBarItemContainer() -> some View {
        return self.frame(
            minWidth: 0,
            idealWidth: .infinity,
            alignment: .top
        )
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .background(.ultraThinMaterial)
    }
}
