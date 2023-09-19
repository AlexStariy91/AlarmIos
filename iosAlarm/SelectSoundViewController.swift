//
//  SelectSoundViewController.swift
//  iosAlarm
//
//  Created by Alexander Starodub on 12.06.2023.
//

import UIKit
import AVFoundation

protocol SelectSoundViewControllerDelegate: AnyObject{
    func didSaveSound()
}

final class SelectSoundViewController: UIViewController {
    
    @IBOutlet weak var selectSoundTableView: UITableView!
    var playSound: AVAudioPlayer?
    var alarm: Alarm?
    var soundIsPlaying = false
    weak var delegate: SelectSoundViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sound"
        initUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.didSaveSound()
    }
    
    private func initUI() {
        selectSoundTableView.register(UINib(nibName: "SelectSoundTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectSoundTableViewCell")
    }
    
    private func playSound (melodyTitle: String) {
        guard let url = Bundle.main.url(forResource: melodyTitle, withExtension: "wav") else { return }
        do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            playSound = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            if !soundIsPlaying{
                playSound?.play()
                soundIsPlaying = true
            } else {
                soundIsPlaying = false
            }
            } catch let error {
                print(error.localizedDescription)
            }
    }
}

// MARK: TableViewDataSource, TableViewDelegate
extension SelectSoundViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSoundTableViewCell", for: indexPath) as! SelectSoundTableViewCell
        cell.fillUpCellWithData(alarm: alarm!, indexPathRow: indexPath.row)
        if cell.soundTitle.text == alarm!.sound {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }      
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playSound(melodyTitle: arrayOfSounds[indexPath.row])
        let selectedSound = self.selectSoundTableView.cellForRow(at: indexPath) as! SelectSoundTableViewCell
        alarm?.sound = selectedSound.soundTitle.text!
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        soundIsPlaying = false
    }
}
