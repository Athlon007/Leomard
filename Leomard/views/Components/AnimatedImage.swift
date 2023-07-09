//
//  WebView.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI
import WebKit
import Combine

struct AnimatedImage: NSViewRepresentable {
    let link: String
    @Binding var imageHeight: CGFloat
    
    func makeNSView(context: Context) -> WKWebViewNonInteractable {
        return WKWebViewNonInteractable()

    }
    
    func updateNSView(_ nsView: WKWebViewNonInteractable, context: Context) {
        let html = """
               <html>
               <head>
               <style>
               html, body {
                   margin: 0;
                   padding: 0;
                   overflow: hidden;
               }
               img {
                   width: 100%;
                   height: 100%;
                   object-fit: contain;
               }
               </style>
               </head>
               <body>
               <img src="\(link)">
               </body>
               </html>
               """
        nsView.loadHTMLString(html, baseURL: nil)
    }
}

struct YoutubePlayer: NSViewRepresentable {
    let link: String
    @Binding var imageHeight: CGFloat
    

    func makeNSView(context: Context) -> WKWebVideoNonInteractable {
        return WKWebVideoNonInteractable()
    }
    
    func updateNSView(_ nsView: WKWebVideoNonInteractable, context: Context) {
        var url = self.link
        if url.contains("youtube.com/watch?v=") {
            url = url.replacingOccurrences(of: "/watch?v=", with: "/embed/")
        } else if link.contains("youtu.be") {
            url = url.replacingOccurrences(of: "youtu.be/", with: "youtube.com/embed/")
        }
        
        let html = """
               <html>
               <head>
               <style>
               html, body {
                   margin: 0;
                   padding: 0;
                   overflow: hidden;
               }
               iframe {
                   width: 100%;
                   height: 100%;
                   object-fit: contain;
               }
               </style>
               </head>
               <body>
               <iframe src="\(url)">
               </body>
               </html>
               """
        nsView.loadHTMLString(html, baseURL: nil)
    }
}


class WKWebViewNonInteractable: WKWebView
{
    override public func scrollWheel(with event: NSEvent)
    {
        self.nextResponder?.scrollWheel(with: event)
    }
    
    override public func mouseDown(with event: NSEvent)
    {
        self.nextResponder?.mouseDown(with: event)
    }
    
    override public func mouseUp(with event: NSEvent)
    {
        self.nextResponder?.mouseUp(with: event)
    }
    
    override public func rightMouseDown(with event: NSEvent) {
        self.nextResponder?.rightMouseDown(with: event)
    }
}

class WKWebVideoNonInteractable: WKWebView
{
    override public func scrollWheel(with event: NSEvent)
    {
        self.nextResponder?.scrollWheel(with: event)
    }
    
    override public func rightMouseDown(with event: NSEvent) {
        self.nextResponder?.rightMouseDown(with: event)
    }
}
