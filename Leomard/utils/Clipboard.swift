//
//  Clipboard.swift
//  Leomard
//
//  Created by Konrad Figura on 11/07/2023.
//

import Foundation
import SwiftUI

struct Clipboard {
    static func copyToClipboard(text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: NSPasteboard.PasteboardType.string)
    }
    
    static func copyImageToClipboard(imageLink: String) {
        guard let imageURL = URL(string: imageLink) else {
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: imageURL) { data, response, error in
            guard let data = data, let image = NSImage(data: data) else {
                return
            }
            
            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects([image] as [NSPasteboardWriting])
        }
        
        task.resume()
    }
}
