//
//  DateDisplayView.swift
//  Leomard
//
//  Created by Konrad Figura on 04/07/2023.
//

import Foundation
import SwiftUI

struct DateDisplayView: View {
    let date: Date
    @State var showRealTime: Bool = false
    @State var noBrackets: Bool = false
    @State var noTapAction: Bool = false
    @State var prettyFormat: Bool = false
    
    var body: some View {
        if showRealTime {
            Text(formatDate())
                .onTapGesture {
                    toggleShowRealTime()
                }
        } else {
            Text(getNiceText())
                .onTapGesture {
                    toggleShowRealTime()
                }
        }
    }
    
    func toggleShowRealTime() {
        if noTapAction {
            return
        }
        
        self.showRealTime = !self.showRealTime
    }
    
    func formatDate() -> String {
        if prettyFormat {
            return formatDatePretty()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var output = dateFormatter.string(from: self.date)
        
        if !noBrackets {
            output = "(\(output))"
        }
        
        return output
    }
    
    func formatDatePretty() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        var output = dateFormatter.string(from: self.date)
        
        if !noBrackets {
            output = "(\(output))"
        }
        
        return output
    }
    
    func getNiceText() -> String {
        let elapsed = DateFormatConverter.getElapsedTime(from: self.date)
        var output = ""
        if elapsed.days == 0 && elapsed.hours == 0 && elapsed.minutes == 0 {
            output = "\(elapsed.seconds) seconds ago"
        } else if elapsed.days == 0 && elapsed.hours == 0 {
            output = "\(elapsed.minutes) minutes ago"
        } else if elapsed.days == 0 {
            output = "\(elapsed.hours) hours ago"
        } else {
            output = "\(elapsed.days) days ago"
        }
        
        if !noBrackets {
            output = "(\(output))"
        }
        
        return output
    }
}
