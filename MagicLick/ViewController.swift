//
//  ViewController.swift
//  MagicLick
//
//  Created by Yuichiro Kondo on 2019/02/02.
//  Copyright © 2019 Yuichiro Kondo. All rights reserved.
//

import UIKit
import Beethoven
import Pitchy
import Hue
import Cartography

class ViewController: UIViewController {
    lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        //label.font = UIFont.boldSystemFont(ofSize: 65)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "DCD9DB")
        label.textAlignment = .center
        //label.numberOfLines = 0
        label.numberOfLines = 100
        //    label.adjustsFontSizeToFitWidth = true
        //    label.sizeToFit()
        return label
    }()

    lazy var offsetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()

    lazy var holeNoLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "DCD9DB")
        label.textAlignment = .center
        label.numberOfLines = 100
        return label
    }()

    lazy var actionButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 20
        button.backgroundColor = UIColor(hex: "3DAFAE")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(UIColor.white, for: UIControlState())
        
        button.addTarget(self, action: #selector(ViewController.actionButtonDidPress(_:)),
                         for: .touchUpInside)
        button.setTitle("Start".uppercased(), for: UIControlState())
        
        return button
        }()

    lazy var pitchEngine: PitchEngine = { [weak self] in
        let config = Config(bufferSize: 1024, estimationStrategy: .yin)
        
        let pitchEngine = PitchEngine(config: config, delegate: self)
        //    pitchEngine.levelThreshold = -30.0
        pitchEngine.levelThreshold = -20.0
        return pitchEngine
        }()
    
    var previousPitchStr = ""
    
    var thresholdSlider : UISlider = {
        let slider = UISlider()
        slider.frame.size.width = 300
        slider.sizeToFit()
        slider.minimumValue = -40
        slider.maximumValue = -10
        slider.setValue(-20, animated: true)
        slider.addTarget(
            self,
            action: #selector(ViewController.sliderChange(sender:)),
            for:UIControlEvents.valueChanged
        )
        return slider
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tuner".uppercased()
        view.backgroundColor = UIColor(hex: "111011")
        
        [noteLabel, actionButton, offsetLabel, holeNoLabel].forEach {
            view.addSubview($0)
        }
        
        //kondo test
        //self.isPitchChained(previousPitch: "C4", nextPitch: "A4");
        //self.isPitchChained(previousPitch: "C4", nextPitch: "B5");
        //self.isPitchChained(previousPitch: "C4", nextPitch: "C3");
        //kondo test
        setupLayout()
    }

    // MARK: - Action methods
    
    @objc func actionButtonDidPress(_ button: UIButton) {
        let text = pitchEngine.active
            ? NSLocalizedString("Start", comment: "").uppercased()
            : NSLocalizedString("Stop", comment: "").uppercased()
        
        if !pitchEngine.active {
            print("noteLabel is empty.")
            noteLabel.text = ""
            holeNoLabel.text = ""
        }
        
        button.setTitle(text, for: .normal)
        button.backgroundColor = pitchEngine.active
            ? UIColor(hex: "3DAFAE")
            : UIColor(hex: "E13C6C")
        
        //noteLabel.text = "--"
        pitchEngine.active ? pitchEngine.stop() : pitchEngine.start()
        offsetLabel.isHidden = !pitchEngine.active
    }
    
    func setupLayout() {
        //    let totalSize = UIScreen.main.bounds
        
        constrain(actionButton, noteLabel, offsetLabel, holeNoLabel) {
            actionButton, noteLabel, offsetLabel, holeNoLabel in
            
            let superview = actionButton.superview!
            
            //      actionButton.top == superview.top + (totalSize.height - 30) / 2
            actionButton.top == superview.bottom - 50
            actionButton.centerX == superview.centerX
            actionButton.width == 280
            actionButton.height == 50
            
            offsetLabel.bottom == actionButton.top - 10
            offsetLabel.leading == superview.leading
            offsetLabel.trailing == superview.trailing
            offsetLabel.height == 80
            
            //      noteLabel.bottom == offsetLabel.top - 20
            //      noteLabel.leading == superview.leading
            //      noteLabel.trailing == superview.trailing
            //      noteLabel.height == 80
            
            thresholdSlider.frame == CGRect(x:0,y:100,width:300,height:50)
            self.view.addSubview(thresholdSlider)
            
            noteLabel.top == superview.top + 20
            noteLabel.leading == superview.leading
            noteLabel.trailing == superview.trailing
            noteLabel.bottom == offsetLabel.top / 2
            
            holeNoLabel.top == noteLabel.bottom
            holeNoLabel.leading == superview.leading
            holeNoLabel.trailing == superview.trailing
            holeNoLabel.bottom == offsetLabel.top
        }
    }
    
    // MARK: - UI
    
    private func offsetColor(_ offsetPercentage: Double) -> UIColor {
        let color: UIColor
        
        switch abs(offsetPercentage) {
        case 0...5:
            color = UIColor(hex: "3DAFAE")
        case 6...25:
            color = UIColor(hex: "FDFFB1")
        default:
            color = UIColor(hex: "E13C6C")
        }
        
        return color
    }
}

// MARK: - PitchEngineDelegate

extension ViewController: PitchEngineDelegate {
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        if pitch.frequency < 250 { return} //C4
        if pitch.frequency > 2100 { return } //C7
        
        let offsetPercentage = pitch.closestOffset.percentage
        let absOffsetPercentage = abs(offsetPercentage)
        guard absOffsetPercentage > 1.0 else {
            return
        }
        
        var pitchStr = pitch.note.string
        if let range = pitchStr.range(of:"#"){
            pitchStr.removeSubrange(range)
        }
        if previousPitchStr == pitchStr {return}
        previousPitchStr = pitchStr
        noteLabel.text = noteLabel.text! + pitchStr + " "
        
        let pitchColor = decidePitchColor(frequency: pitch.frequency)
        noteLabel.textColor = pitchColor
        
        var pitchToNum = PitchToNumber()
        pitchToNum.SetKey(key: "C")
        holeNoLabel.text = holeNoLabel.text! + pitchToNum.GetNumberOfHole(pitch: pitchStr)
        
        let prefix = offsetPercentage > 0 ? "+" : "-"
        let color = offsetColor(offsetPercentage)
        
        offsetLabel.text = "\(prefix)" + String(format:"%.2f", absOffsetPercentage) + "%"
        offsetLabel.textColor = color
        offsetLabel.isHidden = false
    }
    
    func decidePitchColor(frequency: Double) -> UIColor{
        let color: UIColor
        switch frequency{
        case 0...250:
            color = UIColor(hex: "8b008b")
        case 250...1000:
            color = UIColor(hex: "9932cc")
        case 1001...1500:
            color = UIColor(hex: "ba55d3")
        case 1501...2000:
            color = UIColor(hex: "da70d6")
        case 2001...2500:
            color = UIColor(hex: "dda0dd")
        default:
            color = UIColor(hex: "E13C6C")
        }
        return color
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        print(error)
    }
    
    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        //print("Signal Level \(pitchEngine.signalLevel) Below level threshold \(pitchEngine.levelThreshold).")
    }
    
    @objc
    func sliderChange(sender: UISlider){
        print(sender.value)
        pitchEngine.levelThreshold = sender.value
    }
    
    private func isPitchChained(previousPitch: String, nextPitch: String) {
        print("\(#function)(\(previousPitch),\(nextPitch))")
        print("pre:\(convertPitchToInt(pitch: previousPitch)),nxt:\(convertPitchToInt(pitch: nextPitch))")
        return
    }
    private func convertPitchToInt(pitch: String) -> Int{
        if pitch.count > 2{
            print("\(#function) Pitch \(pitch) length Over...")
            return 0
        }
        let octave     = pitch.suffix(1)
        let soundName  = pitch.prefix(1)
        return 10 * Int(octave)! + soundValue(sound: String(soundName))
    }
    private func soundValue(sound: String) -> Int{
        switch sound {
        case "A": return 1
        case "B": return 2
        case "C": return 3
        case "D": return 4
        case "E": return 5
        case "F": return 6
        case "G": return 7
        default:return 0
        }
    }


}

