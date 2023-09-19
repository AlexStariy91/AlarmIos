//
//  ViewController.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 08.06.2023.
//

import UIKit
import UserNotifications

final class ViewController: UIViewController {
    
    @IBOutlet weak private var alarmsTableView: UITableView!
    @IBOutlet weak var noAlarmsLabel: UILabel!
    var alarms = SavedAlarms().readSavedAlarms()
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissions()
        Utils.shared.checkPendingNotificationsAndSetAlarmIsOnProperty(notificationCenter, alarms)
        addTurnOffAlarmObservers()
        initUI()
        alarmsTableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.shared.showPendingNotifications(notificationCenter)
    }
    
    private func addTurnOffAlarmObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(setAlarmIsOnProperty), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeDeliveredNotifications), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAlarmsTableView), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setAlarmIsOnProperty), name: Notification.Name("SetAlarmIsOnProperty"), object: nil)
    }
    
    private func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SetAlarmIsOnProperty"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func refreshAlarmsTableView(_ notification: Notification){
        DispatchQueue.main.async {
            self.alarmsTableView.reloadData()
        }
    }
    
    @objc func removeDeliveredNotifications(_ notification: Notification) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    @objc func setAlarmIsOnProperty(_ notification: Notification){
        Utils.shared.checkPendingNotificationsAndSetAlarmIsOnProperty(notificationCenter, alarms)
    }
    
    private func initUI() {
        alarmsTableView.register(UINib(nibName: "AlarmTableViewCell", bundle: nil), forCellReuseIdentifier: "AlarmTableViewCell")
    }
    
    private func requestPermissions(){
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) {  permissionGranted, error in
            if (!permissionGranted){
                print("Permission denied!")
            }
        }
    }
    
    
    @IBAction func addNewAlarmButton(_ sender: Any) {
        notificationCenter.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                if (settings.authorizationStatus == .authorized){
                    self.openSettingsOfAlarmVC()
                } else {
                    self.repeatingAskUserPermissions()
                }
            }
        }
    }
    
    private func openSettingsOfAlarmVC(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let presentSetiingsOfAlarmVC = storyBoard.instantiateViewController(withIdentifier: "SettingsOfAlarmNavigationController") as! UINavigationController
        guard let settingsOfAlarmVC = presentSetiingsOfAlarmVC.viewControllers.first as? SettingsOfAlarmViewController else {return}
        settingsOfAlarmVC.delegate = self
        settingsOfAlarmVC.alarm = Alarm(sound: "Nice", snooze: true, weekDays: [WeekDays]())
        self.present(presentSetiingsOfAlarmVC, animated: true)
        self.setEditing(false, animated: false)
    }
    
    private func repeatingAskUserPermissions() {
        let repeatedUserRequestNotificationsAC = UIAlertController(title: "Enable notifications", message: "To add alarm you must enable notifications in settings", preferredStyle: .alert)
        let goToSettings = UIAlertAction(title: "Settings", style: .default){
            (_) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
            if (UIApplication.shared.canOpenURL(settingsURL)){
                UIApplication.shared.open(settingsURL) { (_) in }
            }
        }
        repeatedUserRequestNotificationsAC.addAction(goToSettings)
        repeatedUserRequestNotificationsAC.addAction(UIAlertAction(title: "Cancel", style: .default))
        self.present(repeatedUserRequestNotificationsAC, animated: true)
    }
}




// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noAlarmsLabel.isHidden = alarms.count > 0
        if alarms.count > 0 {
            self.navigationItem.leftBarButtonItem = self.editButtonItem
        } else {
            self.navigationItem.leftBarButtonItem = .none
        }
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as! AlarmTableViewCell
        let alarm = alarms[indexPath.row]
        cell.fillUpCellWithData(alarm: alarm, indexPathRow: indexPath.row)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .left)
            Utils.shared.deleteOldPendingNotifications(alarm: alarms[indexPath.row], notificationCenter: notificationCenter)
            alarms.remove(at: indexPath.row)
            if alarms.count == 0 {
                self.setEditing(false, animated: false)
            }
            SavedAlarms().saveAlarm(arrayOfAlarms: alarms)
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.setEditing(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.setEditing(false, animated: false)
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.alarmsTableView.setEditing(editing, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let presentSettingsOfAlarmVC = storyboard.instantiateViewController(withIdentifier: "SettingsOfAlarmNavigationController") as! UINavigationController
        guard let childSettingsOfAlarmVC = presentSettingsOfAlarmVC.viewControllers.first as? SettingsOfAlarmViewController else {return}
        childSettingsOfAlarmVC.alarm = alarms[indexPath.row]
        childSettingsOfAlarmVC.navigationItem.title = "Edit"
        childSettingsOfAlarmVC.delegate = self
        present(presentSettingsOfAlarmVC, animated: true)
        self.setEditing(false, animated: false)
    }
}


// MARK: SettingsOfAlarmViewControllerDelegate
extension ViewController: SettingsOfAlarmViewControllerDelegate {
    func didSaveAlarm(_ saveAlarm: Alarm) {
        if let index = alarms.firstIndex(of: saveAlarm){
            alarms[index] = saveAlarm
        } else {
            alarms.append(saveAlarm)
        }
        alarms.sort{$0.date! < $1.date!}
        SavedAlarms().saveAlarm(arrayOfAlarms: alarms)
        DispatchQueue.main.async {
            self.alarmsTableView.reloadData()
        }
        self.setEditing(false, animated: false)
    }
}
extension ViewController: AlarmTableViewCellDelegate {
    func didChangeAlarmState(alarm: Alarm) {
        if alarm.alarmIsOn {
            Utils.shared.createNotification(datePicker: nil, alarm: alarm, notificationCenter: notificationCenter)
            Utils.shared.showPendingNotifications(notificationCenter)
        } else {
            Utils.shared.deleteOldPendingNotifications(alarm: alarm, notificationCenter: notificationCenter)
        }
    }
}
