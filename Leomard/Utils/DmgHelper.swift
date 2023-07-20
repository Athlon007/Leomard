//
//  DmgHelper.swift
//  Leomard
//
//  Created by Konrad Figura on 20/07/2023.
//

import Foundation
import AppKit

struct DmgHelper {
    static func mountDmg(_ dmgPath: String) -> String? {
        let process = Process()
        process.launchPath = "/usr/bin/hdiutil"
        process.arguments = ["attach", dmgPath]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        
        process.launch()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: outputData, encoding: .utf8) {
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    func openMountedDMG(mountedPath: String) {
        NSWorkspace.shared.open(URL(string: mountedPath)!)
    }
}
