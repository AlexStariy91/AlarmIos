//
//  SettingsOfAlarmViewController.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 12.06.2023.
//
import UserNotifications
import UIKit

protocol SettingsOfAlarmViewControllerDelegate: AnyObject{
    func didSaveAlarm(_ saveAlarm: Alarm)
}

final class SettingsOfAlarmViewController: UIViewController {
    
    @IBOutlet weak var settingsAlarmTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var alarm: Alarm!
    weak var delegate: SettingsOfAlarmViewControllerDelegate?
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        datePicker.overrideUserInterfaceStyle = .dark
        if alarm.date != nil {
            datePicker.date = alarm.date!
        }
    }
    
    private func initUI(){
        settingsAlarmTableView.register(UINib(nibName: "SettingsOfAlarmTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsOfAlarmTableViewCell")
    }
    
    @IBAction func saveAction(_ sender: Any) {
        alarm.alarmIsOn = true
        Utils.shared.createNotification(datePicker: datePicker, alarm: alarm, notificationCenter: notificationCenter)
        self.delegate?.didSaveAlarm(alarm)
        Utils.shared.showPendingNotifications(notificationCenter)
        dismiss(animated: true)
    }
    
    @IBAction func cancelAlarmSettingsController(_ sender: Any) {
        dismiss(animated: true)
    }
}


//MARK: TableViewDelegate, TableViewDataSource
extension SettingsOfAlarmViewController: UITableViewDelegate, UITableViewDataSource{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "SettingsOfAlarmTableViewCell", for: indexPath) as! SettingsOfAlarmTableViewCell
        cell.fillUpCellWithData(alarm: alarm, indexPathRow: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        switch indexPath.row {
        case 0:
            let pushRepeatDaysVC = storyBoard.instantiateViewController(withIdentifier: "RepeatDaysViewController") as! RepeatDaysViewController
            pushRepeatDaysVC.alarm = alarm
            pushRepeatDaysVC.delegate = self
            navigationController?.pushViewController(pushRepeatDaysVC, animated: true)
        case 1:
            let pushSelectSoundVC = storyBoard.instantiateViewController(withIdentifier: "SelectSoundViewController") as! SelectSoundViewController
            pushSelectSoundVC.alarm = alarm
            pushSelectSoundVC.delegate = self
            navigationController?.pushViewController(pushSelectSoundVC, animated: true)
        default: break
        }
    }
}

//MARK: SelectSoundViewControllerDelegate, RepeatDaysViewControllerDelegate
extension SettingsOfAlarmViewController: SelectSoundViewControllerDelegate, RepeatDaysViewControllerDelegate{
    func didSaveRepeatDays() {
        settingsAlarmTableView.reloadData()
    }
    
    func didSaveSound() {
        settingsAlarmTableView.reloadData()
    }       
}
