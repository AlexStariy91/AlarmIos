//
//  SettingsOfAlarmTableViewCell.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 20.06.2023.
//

import UIKit

class SettingsOfAlarmTableViewCell: UITableViewCell {
    private var settingsAlarm: Alarm?
    @IBOutlet private weak var snoozeSwitch: UISwitch!
    @IBOutlet private weak var contentOfCell: UILabel!
    @IBOutlet private weak var nameOfCell: UILabel!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var highlightView: UIView!
    
    @IBAction func snoozeSwitchAction(_ sender: Any) {
        guard let alarm = settingsAlarm else {return}
        alarm.snooze = snoozeSwitch.isOn
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separator.overrideUserInterfaceStyle = .dark
    }
    
    func fillUpCellWithData(alarm: Alarm, indexPathRow: Int){
        settingsAlarm = alarm
        switch indexPathRow{
        case 0:
            nameOfCell.text = "Repeat"
            var selectedDays = ""
            if alarm.weekDays.isEmpty {
                selectedDays = "Never"
            }
            for day in alarm.weekDays{
                switch alarm.weekDays.count {
                case 1:
                    selectedDays = "Every " + day.fullDayName
                case 1...6:
                    selectedDays += day.abbreviatedDayName + " "
                case 6...:
                    selectedDays = "Every day"
                default: break
                }
            }
            contentOfCell.text = selectedDays.trimmingCharacters(in: .whitespaces)
        case 1:
            nameOfCell.text = "Sound"
            contentOfCell.text = alarm.sound
        case 2:
            nameOfCell.text = "Snooze"
            contentOfCell.isHidden = true
            snoozeSwitch.isHidden = false
            separator.isHidden = true
            highlightView.isHidden = true
            snoozeSwitch.setOn(alarm.snooze, animated: false)
        default: break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.4) {
            self.highlightView.alpha = highlighted ? 0.3 : 0
        }
    }
    
    override func prepareForReuse() {
       super.prepareForReuse()
        snoozeSwitch.isHidden = true
        contentOfCell.isHidden = false
        separator.isHidden = false
    }
}
