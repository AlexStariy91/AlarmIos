//
//  SavedAlarms.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 28.06.2023.
//

import Foundation

class SavedAlarms {
    
    public func saveAlarm(arrayOfAlarms: [Alarm]){
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(arrayOfAlarms)
            let json = String(data: jsonData, encoding: .utf8) ?? "{}"
            let userDefaults = UserDefaults.standard
            userDefaults.set(json, forKey: "arrayOfAlarms")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func readSavedAlarms() -> [Alarm]{
        do {
            let json = UserDefaults.standard.string(forKey: "arrayOfAlarms") ?? "{}"
            let jsonDecoder = JSONDecoder()
            guard let jsonData = json.data(using: .utf8) else {return [Alarm]()}
            let arrayOfAlarms: [Alarm] = try jsonDecoder.decode([Alarm].self, from: jsonData)
            return arrayOfAlarms
        } catch {}
        return [Alarm]()
    }
}
