//
//  AlarmInformationClass.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 15.06.2023.
//

import Foundation

let arrayOfSounds = ["Nice", "Uplift", "Smooth", "Alarm", "Sencha", "Islandy", "Pluck", "Silk", "Mechanic", "Chill"]

enum WeekDays: Int, Codable, Comparable{
        
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    case Sunday = 1
    
    var fullDayName: String {
        switch self {
        case .Monday: return "Monday"
        case .Tuesday: return "Tuesday"
        case .Wednesday: return "Wednesday"
        case .Thursday: return "Thursday"
        case .Friday: return "Friday"
        case .Saturday: return "Saturday"
        case .Sunday: return "Sunday"
        }
    }
    
    var abbreviatedDayName: String{
        switch self {
        case .Monday: return "Mon"
        case .Tuesday: return "Tue"
        case .Wednesday: return "Wed"
        case .Thursday: return "Thu"
        case .Friday: return "Fri"
        case .Saturday: return "Sat"
        case .Sunday: return "Sun"
        }
    }

    
    static func < (lhs: WeekDays, rhs: WeekDays) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

}

class Alarm: Codable, Equatable {
    var sound: String
    var snooze: Bool = false
    var weekDays = [WeekDays]()
    var id = UUID().uuidString
    var alarmIsOn: Bool = false
    var date: Date?
    
    init(sound: String, snooze: Bool, weekDays: [WeekDays]) {
        self.sound = sound
        self.snooze = snooze
        self.weekDays = weekDays
    }
    
    public static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func alarmTime (dateFromPicker date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
}
