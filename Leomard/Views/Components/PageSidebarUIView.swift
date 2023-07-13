//
//  PageSidebarUIView.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI
import MarkdownUI

struct PageSidebarUIView: View {
    @Binding var siteView: SiteView?
    
    var body: some View {
        LazyVStack {
            if siteView!.site.banner != nil {
                AsyncImage(url: URL(string: siteView!.site.banner!)!, content: { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 600, maxHeight: .infinity)
                    default:
                        VStack {}
                    }
                })
                .padding(.trailing, -25)
            }
            Text(siteView!.site.name)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 24))
            Spacer()
            if siteView!.site.sidebar != nil {
                let banner = MarkdownContent(siteView!.site.sidebar!)
                Markdown(banner)
                Spacer()
            }
            
        }
        .padding(5)
        .background(Color(.textBackgroundColor))
    }
}
