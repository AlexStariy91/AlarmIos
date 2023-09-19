//
//  RepeatDaysTableViewCell.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 15.06.2023.
//

import UIKit

class RepeatDaysTableViewCell: UITableViewCell {
    @IBOutlet weak var titleOfDay: UILabel!    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var selectedDayCheckmark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separator.overrideUserInterfaceStyle = .dark
    }
    
    func fillUpCellWithData(alarm: Alarm, indexPathRow: Int){
        titleOfDay.text = "Every \(WeekDays(rawValue: indexPathRow + 1)!.fullDayName)"
        if indexPathRow == 6 {
            separator.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            selectedDayCheckmark.isHidden = false
        } else {
            selectedDayCheckmark.isHidden = true
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
            UIView.animate(withDuration: 0.4) {
            self.highlightView.alpha = highlighted ? 0.3 : 0
        }
    }
}
