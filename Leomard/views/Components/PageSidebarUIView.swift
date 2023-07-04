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
        VStack {
            VStack {
                if siteView!.site.banner != nil {
                    VStack {
                        let content = MarkdownContent("![](" + siteView!.site.banner! + ")")
                        Markdown(content)
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                maxHeight: 200,
                                alignment: .leading
                            )
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: 200
                    )
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
}
