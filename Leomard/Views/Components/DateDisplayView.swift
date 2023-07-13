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

        let day = Calendar.current.dateComponents([.day], from: date).day
        var suffix = "th"
        if day == 1 || day == 21 || day == 31 {
            suffix = "st"
        } else if day == 2 || day == 22 {
            suffix = "nd"
        } else if day == 3 || day == 23 {
            suffix = "rd"
        }
        
        dateFormatter.dateFormat = "d'\(suffix)' MMMM yyyy"
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
            output = "\(elapsed.seconds) second\(elapsed.seconds > 1 ? "s" : "") ago"
        } else if elapsed.days == 0 && elapsed.hours == 0 {
            output = "\(elapsed.minutes) minute\(elapsed.minutes > 1 ? "s" : "") ago"
        } else if elapsed.days == 0 {
            output = "\(elapsed.hours) hour\(elapsed.hours > 1 ? "s" : "") ago"
        } else {
            output = "\(elapsed.days) day\(elapsed.days > 1 ? "s" : "") ago"
        }
        
        if !noBrackets {
            output = "(\(output))"
        }
        
        return output
    }
}
