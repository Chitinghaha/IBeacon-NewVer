//
//  ViewController.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/1.
//

import UIKit

class HomePageViewController: UIViewController {

    
    @IBOutlet weak var nearestAreaView: UIView!
    
    @IBOutlet weak var nearbyAreaView: UIView!
    
    @IBOutlet weak var soundSettingView: UIView!
    
    
    @IBOutlet weak var nearestAreaButton: UIButton!
    
    @IBOutlet weak var nearbyAreaButton: UIButton!
    
    @IBOutlet weak var soundSettingButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setAccessibiluty()
    }

    func setAccessibiluty() {
        self.nearestAreaButton.accessibilityLabel = AccessibilityConstants.NearestAreaButton
        
        self.nearbyAreaButton.accessibilityLabel = AccessibilityConstants.NearbyAreaButton
        
        self.soundSettingButton.accessibilityLabel = AccessibilityConstants.SoundSettingButton
    }

    @IBAction func onclickNearestAreaButton(_ sender: Any) {
    }
    
    @IBAction func onclickNearbyAreaButton(_ sender: Any) {
    }
    
    @IBAction func onclickSoundSettingButton(_ sender: Any) {
        
    }
    
    
    
    
}

