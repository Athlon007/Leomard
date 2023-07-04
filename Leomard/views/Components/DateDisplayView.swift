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
    
    var body: some View {
        if showRealTime {
            Text("(\(formatDate()))")
                .onTapGesture {
                    toggleShowRealTime()
                }
        } else {
            let elapsed = DateFormatConverter.getElapsedTime(from: self.date)
            if elapsed.days == 0 && elapsed.hours == 0 && elapsed.minutes == 0 {
                Text("(\(elapsed.seconds) seconds ago)")
                    .onTapGesture {
                        toggleShowRealTime()
                    }
            } else if elapsed.days == 0 && elapsed.hours == 0 {
                Text("(\(elapsed.minutes) minutes ago)")
                    .onTapGesture {
                        toggleShowRealTime()
                    }
            } else if elapsed.days == 0 {
                Text("(\(elapsed.hours) hours ago)")
                    .onTapGesture {
                        toggleShowRealTime()
                    }
            } else {
                Text("(\(elapsed.days) days ago)")
                    .onTapGesture {
                        toggleShowRealTime()
                    }
            }
        }
    }
    
    func toggleShowRealTime() {
        self.showRealTime = !self.showRealTime
    }
    
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: self.date)
    }
}
