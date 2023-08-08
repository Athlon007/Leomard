//
//  MarkdownEditor.swift
//  Leomard
//
//  Created by Konrad Figura on 03/08/2023.
//

import Foundation
import SwiftUI
import MarkdownUI
import HighlightedTextEditor

struct MarkdownEditor: View {
    @Binding var bodyText: String
    let contentView: ContentView
    
    @State var selectRange: NSRange = .init(location: 0, length: 0)
    let editorButtonsFont: Font = .custom(
        "AmericanTypewriter",
        fixedSize: NSFont.preferredFont(forTextStyle: .body).xHeight * 2)
    @State var adjustCursorBy: Int = 0
    @State var showInsertLink: Bool = false
    @State var insertLinkText: String = ""
    @State var insertLinkUrl: String = ""
    
    @State var editorInsertionMode: EditorInsertionMode = .none
    @State var autoInsertCharacterAdded: Bool = false
    @State var previousBodyLength: Int = 0
    
    @State var isUploadingImage: Bool = false
    
    @State var preview: Bool = false
    
    let maxEditorHeight: Int = 13
    
    var body: some View {
        VStack {
            HStack {
                toolbar
            }
            .frame(maxWidth: .infinity, maxHeight: 16, alignment: .leading)
            .buttonStyle(.link)
            Spacer()
            VStack {
                if preview {
                    previewView
                } else {
                    editorBody
                        .disabled(isUploadingImage)
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .leading
            )
            .overlay {
                uploadingImageOverlay
            }
            .alert("Insert Link", isPresented: $showInsertLink, actions: {
                TextField("Text Displayed", text: $insertLinkText)
                TextField("URL", text: $insertLinkUrl)
                Button(action: {
                    addToBody(" [\(insertLinkText)](\(insertLinkUrl))", on: .rightSide)
                }, label: { Text("Add") })
                Button(role: .cancel, action: {}, label: { Text("Cancel") })
            })
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 2.5 * NSFont.preferredFont(forTextStyle: .body).xHeight * CGFloat(integerLiteral: getLineCount()),
            maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var toolbar: some View {
        Button(action: {
            addToBody("**", on: .bothSides)
        }, label: {
            Image(systemName: "bold")
        })
        .help("Bold")
        
        Button(action: {
            addToBody("*", on: .bothSides)
        }, label: {
            Image(systemName: "italic")
        })
        .help("Italic")
        
        Button(action: {
            insertLinkText = ""
            insertLinkUrl = ""
            showInsertLink = true
        }, label: {
            Image(systemName: "link")
        })
        .help("Link")
        
        Button(action: addImage, label: {
            Image(systemName: "photo")
        })
        .help("Add Image")
        
        Button(action: {
            addToBody("# ", on: .leftSide)
        }, label: {
            Text("H")
                .font(editorButtonsFont)
        })
        .help("Header")
        
        Button(action: {
            addToBody("~~", on: .bothSides)
        }, label: {
            Image(systemName: "strikethrough")
        })
        .help("Strikethrough")
        
        Button(action: {
            addToBody("> ", on: .leftSide)
            editorInsertionMode = .quote
        }, label: {
            Image(systemName: "quote.closing")
        })
        .help("Quote")
        
        Button(action: {
            addToBody("- ", on: .leftSide)
            editorInsertionMode = .bulletpoint
        }, label: {
            Image(systemName: "list.bullet")
        })
        .help("List")
        
        Spacer()
        
        Toggle("Preview", isOn: $preview)
            .toggleStyle(.switch)
            .frame(maxWidth: 100)
    }
    
    @ViewBuilder
    private var editorBody: some View {
        HighlightedTextEditor(text: $bodyText, highlightRules: .markdown)
            .onSelectionChange { (range: NSRange) in
                selectRange = range
                updateAutoInsertMode()
            }
            .introspect { editor in
                if adjustCursorBy != 0 {
                    DispatchQueue.main.async {
                        let range: NSRange = NSMakeRange(selectRange.location + adjustCursorBy, 0)
                        editor.textView.setSelectedRange(range)
                        adjustCursorBy = 0
                    }
                }
                
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.primary, lineWidth: 0.5))
            .frame(
                maxWidth: .infinity,
                minHeight: 3 * NSFont.preferredFont(forTextStyle: .body).xHeight,
                maxHeight: .infinity,
                alignment: .leading
            )
            .lineLimit(5...)
            .font(.system(size: NSFont.preferredFont(forTextStyle: .body).pointSize))
    }
    
    @ViewBuilder
    private var previewView: some View {
        List {
            let content = MarkdownContent(bodyText)
            Markdown(content)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .leading
                )
        }
    }
    
    @ViewBuilder
    private var uploadingImageOverlay: some View {
        if isUploadingImage {
            ProgressView().progressViewStyle(.circular)
        }
    }
    
    // MARK: -
    
    // Makes sure that the lists and quotes are automatically inserted.
    func updateAutoInsertMode() {
        var removing = false
        
        var last = Character("§")
        var secondLast = Character("§")
        if selectRange.location - 2 > 0 && selectRange.location <= bodyText.count {
            let secondLastIndex = bodyText.index(bodyText.startIndex, offsetBy: selectRange.location - 2)
            secondLast = bodyText[secondLastIndex]
            
            let lastIndex = bodyText.index(bodyText.startIndex, offsetBy: selectRange.location - 1)
            last = bodyText[lastIndex]
        }

        if previousBodyLength > bodyText.count && secondLast.isNewline {
            editorInsertionMode = .none
            removing = true
        }
        if !removing {
            if last == "-" && secondLast == "\n" {
                editorInsertionMode = .bulletpoint
            } else if last == ">" && secondLast == "\n" {
                editorInsertionMode = .quote
            }
        }
        
        if previousBodyLength != bodyText.count {
            autoInsertCharacterAdded = false
        }
        
        if last.isNewline && !autoInsertCharacterAdded {
            if editorInsertionMode == .bulletpoint {
                bodyText += "- "
                adjustCursorBy += 2
            } else if editorInsertionMode == .quote {
                bodyText += "> "
                adjustCursorBy += 2
            }
            
            autoInsertCharacterAdded = true
        }
        
        previousBodyLength = bodyText.count
    }
    
    private func addToBody(_ set: String, on: AddOnSides) {
        var location = selectRange.location
        var length = selectRange.length
        if length == 0 {
            // If length is 0, adjust the location and length to select the entire word in bodyText.
            while location > 0 && !bodyText[bodyText.index(bodyText.startIndex, offsetBy: location - 1)].isWhitespace {
                location -= 1
            }
            
            while location + length < bodyText.count && !bodyText[bodyText.index(bodyText.startIndex, offsetBy: location + length)].isWhitespace {
                length += 1
            }
        }
        
        let startIndex = bodyText.index(bodyText.startIndex, offsetBy: location)
        let endIndex = bodyText.index(bodyText.startIndex, offsetBy: location + length)
        if on == .rightSide || on == .bothSides {
            self.bodyText.insert(contentsOf: set, at: endIndex)
        }
        if on == .leftSide || on == .bothSides {
            self.bodyText.insert(contentsOf: set, at: startIndex)
        }
        
        adjustCursorBy += on == .bothSides ? set.count : set.count
    }
    
    func addImage() {
        isUploadingImage = true
        self.contentView.addImage { result in
            isUploadingImage = false
            switch result {
            case .success(let response):
                isUploadingImage = false
                // Otherwise add it to content of the bodyText.
                if bodyText.count > 0 {
                    // If there already is some text, add new line.
                    bodyText += "\n\n"
                }
                
                bodyText += "![](\(response.data.link))\n\n"
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getLineCount() -> Int {
        var count =  bodyText.components(separatedBy: "\n").count + 1
        if count > maxEditorHeight {
            count = maxEditorHeight
        }
        return count
    }
}

enum AddOnSides {
    case leftSide
    case rightSide
    case bothSides
}

enum EditorInsertionMode {
    case none
    case bulletpoint
    case quote
}
