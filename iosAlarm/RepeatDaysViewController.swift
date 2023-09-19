//
//  RepeatDaysViewController.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 12.06.2023.
//

import UIKit

protocol RepeatDaysViewControllerDelegate: AnyObject{
    func didSaveRepeatDays()
}

final class RepeatDaysViewController: UIViewController {
    
    @IBOutlet weak var repeatDaysTableView: UITableView!
    var alarm: Alarm!
    weak var delegate: RepeatDaysViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Repeat"
        initUI()
    }
    
    private func initUI(){
        repeatDaysTableView.register(UINib(nibName:"RepeatDaysTableViewCell", bundle: nil), forCellReuseIdentifier: "RepeatDaysTableViewCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if alarm.weekDays.count > 0 {
            alarm.weekDays = alarm.weekDays.sorted()
        }
        self.delegate?.didSaveRepeatDays()
    }
}

// MARK: - TableViewDataSource, TableViewDelegate
extension RepeatDaysViewController: UITableViewDataSource, UITableViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatDaysTableViewCell", for: indexPath) as! RepeatDaysTableViewCell
        cell.fillUpCellWithData(alarm: alarm, indexPathRow: indexPath.row)
        for day in alarm.weekDays {
            if indexPath.row + 1 == day.rawValue{
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alarm.weekDays.append(WeekDays(rawValue: indexPath.row + 1)!)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarm.weekDays.remove(at: alarm.weekDays.firstIndex(of: WeekDays(rawValue: indexPath.row + 1)!)!)
    }
}



