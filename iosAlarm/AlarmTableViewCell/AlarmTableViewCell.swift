//
//  AlarmTableViewCell.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 10.06.2023.
//

import UIKit

protocol AlarmTableViewCellDelegate: AnyObject {
    func didChangeAlarmState(alarm: Alarm)
}

class AlarmTableViewCell: UITableViewCell {
    private var currentAlarm: Alarm?
    @IBOutlet private weak var highlightView: UIView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var selectedTime: UILabel!
    @IBOutlet private weak var alarmIsOnSwitch: UISwitch!
    @IBOutlet private weak var selectedAbbreviatedDays: UILabel!
    weak var delegate: AlarmTableViewCellDelegate?
    
    @IBAction private func alarmSwitchAction(_ sender: Any) {
        guard let alarm = currentAlarm else {return}
        alarm.alarmIsOn = alarmIsOnSwitch.isOn
        selectedTime.textColor = alarmIsOnSwitch.isOn ? .white : .systemGray
        selectedAbbreviatedDays.textColor = alarmIsOnSwitch.isOn ? .white : .systemGray
        delegate?.didChangeAlarmState(alarm: alarm)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separator.overrideUserInterfaceStyle = .dark
        self.backgroundColor = .black
    }
    
    func fillUpCellWithData(alarm: Alarm, indexPathRow: Int) {
        currentAlarm = alarm
        var selectedDays = ""
        if !alarm.weekDays.isEmpty{
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
        } else {
            selectedDays = "One time alarm"
        }
        alarmIsOnSwitch.setOn(alarm.alarmIsOn, animated: true)
        selectedTime.text = Alarm.alarmTime(dateFromPicker: alarm.date!)
        selectedTime.textColor = alarmIsOnSwitch.isOn ? .white : .systemGray
        selectedAbbreviatedDays.text = selectedDays
        selectedAbbreviatedDays.textColor = alarmIsOnSwitch.isOn ? .white : .systemGray        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.4) {
            self.highlightView.alpha = highlighted ? 0.3 : 0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
