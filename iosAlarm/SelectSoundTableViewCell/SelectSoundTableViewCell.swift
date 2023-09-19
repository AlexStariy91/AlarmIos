//
//  SelectSoundTableViewCell.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 15.06.2023.
//

import UIKit

class SelectSoundTableViewCell: UITableViewCell {

    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var selectedSoundCheckMark: UIImageView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var soundTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separator.overrideUserInterfaceStyle = .dark
    }
    
    func fillUpCellWithData(alarm: Alarm, indexPathRow: Int){
        soundTitle.text = arrayOfSounds[indexPathRow]
        if indexPathRow == arrayOfSounds.count - 1 {
            separator.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            selectedSoundCheckMark.isHidden = false
        } else {
            selectedSoundCheckMark.isHidden = true
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.4) {
            self.highlightView.alpha = highlighted ? 0.3 : 0
        }
    }
}
