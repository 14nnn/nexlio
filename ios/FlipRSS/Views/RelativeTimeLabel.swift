//
//  RelativeTimeLabel.swift
//  FlipRSS
//
//  Created by Darian on 17.10.2024..
//

import SwiftUI

import SwiftUI

struct RelativeTimeLabel: View {
    @State private var currentDate: Date = Date()
    
    let targetDate: Date
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var style: (Text) -> Text
    
    var body: some View {
        style(Text(relativeTime(from: targetDate, currentDate: currentDate)))
            .onReceive(timer) { _ in
                currentDate = Date()
            }
    }
    
    func relativeTime(from date: Date, currentDate: Date) -> String {
        let secondsDifference = Int(date.timeIntervalSince(currentDate))
        let absSeconds = abs(secondsDifference)
        
        if absSeconds < 15 {
            return secondsDifference < 0 ? "just now" : "in a few seconds"
        }
        
        if absSeconds < 60 {
            return secondsDifference < 0 ? "\(absSeconds) seconds ago" : "in \(absSeconds) seconds"
        }
        
        let minutes = absSeconds / 60
        if minutes < 60 {
            if minutes == 1 {
                return secondsDifference < 0 ? "a minute ago" : "in a minute"
            }
            return secondsDifference < 0 ? "\(minutes) minutes ago" : "in \(minutes) minutes"
        }
        
        let hours = minutes / 60
        if hours < 24 {
            if hours == 1 {
                return secondsDifference < 0 ? "an hour ago" : "in an hour"
            }
            let remainingMinutes = minutes % 60
            return secondsDifference < 0 ? "\(hours) hours and \(remainingMinutes) minutes ago" : "in \(hours) hours and \(remainingMinutes) minutes"
        }
        
        let days = hours / 24
        let dateFormatter = DateFormatter()
        
        if days == 1 {
            dateFormatter.dateFormat = "'Yesterday at' HH:mm"
            return dateFormatter.string(from: date)
        } else if days < 7 {
            dateFormatter.dateFormat = "EEEE 'at' HH:mm"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "dd.MM.yyyy. 'at' HH:mm"
            return dateFormatter.string(from: date)
        }
    }
}

#Preview {
    VStack {
        RelativeTimeLabel(targetDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!) { text in
            text.font(.headline).foregroundColor(.blue)
        }
        
        RelativeTimeLabel(targetDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!) { text in
            text.font(.title).foregroundColor(.red)
        }
    }
}
