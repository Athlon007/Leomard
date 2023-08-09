//
//  PostDrafts.swift
//  Leomard
//
//  Created by Konrad Figura on 09/08/2023.
//

import Foundation
import AppKit

final class PostDrafts {
    private func getDraftsDirectoryURL() -> URL? {
        let fileManager = FileManager.default
        let libraryDirectoryURLs = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
        if let libraryDirectoryURL = libraryDirectoryURLs.first {
            let draftsDirectoryURL = libraryDirectoryURL.appendingPathComponent("Leomard").appendingPathComponent("Drafts")
            
            do {
                if !fileManager.fileExists(atPath: draftsDirectoryURL.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                    try fileManager.createDirectory(at: draftsDirectoryURL, withIntermediateDirectories: true)
                    print("Drafts folder created.")
                }
            } catch {
                print(error)
            }
            
            return draftsDirectoryURL
        }
        return nil
    }
    
    func saveDraft(postDraft: PostDraft) {
        let mainFolder = getDraftsDirectoryURL()
        if let folder = mainFolder {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-M-d-hh-mm-ss"
            
            let fileName = "draft_\(dateFormatter.string(from: date)).json"
            var draft = postDraft
            draft.fileName = fileName
            
            let fullPath = folder.appendingPathComponent(fileName)
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            do {
                let jsonData = try jsonEncoder.encode(draft)
                try jsonData.write(to: fullPath)
                print("Draft saved to: \(fullPath.absoluteString)")
            } catch {
                print(error)
            }
        }
    }
    
    func loadDrafts() -> [PostDraft] {
        if let directory = getDraftsDirectoryURL() {
            let pattern = "draft_.*\\.json"
            do {
                let draftsURLs = try FileManager.default.contentsOfDirectory(at: directory,
                                                                             includingPropertiesForKeys: nil)
                let filteredURLs = draftsURLs.filter { url in
                    let fileName = url.lastPathComponent
                    return fileName.range(of: pattern, options: .regularExpression) != nil
                }
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var output: [PostDraft] = .init()
                for url in filteredURLs {
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    let postDraft = try jsonDecoder.decode(PostDraft.self, from: data)
                    output.append(postDraft)
                }
                
                return output
            } catch {
                print(error)
            }
        }
        
        return []
    }
    
    func deleteDraft(draft: PostDraft) {
        if let directory = getDraftsDirectoryURL() {
            let path = directory.appendingPathComponent(draft.fileName)
            if FileManager.default.fileExists(atPath: path.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                do {
                    try FileManager.default.removeItem(at: path)
                } catch {
                    print(error)
                }
            } else {
                print("File \(draft.fileName) does not exist.")
            }
        }
    }
}
