//
//  ViewController.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/1.
//

import UIKit
import CoreLocation

class HomePageViewController: UIViewController {

    
    @IBOutlet weak var nearestAreaView: UIView!
    
    @IBOutlet weak var nearbyAreaView: UIView!
    
    @IBOutlet weak var soundSettingView: UIView!
    
    
    @IBOutlet weak var nearestAreaButton: UIButton!
    
    @IBOutlet weak var nearbyAreaButton: UIButton!
    
    @IBOutlet weak var soundSettingButton: UIButton!
    
    var viewModel: HomePageViewModel = HomePageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setAccessibiluty()
                
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setAccessibiluty() {
        self.nearestAreaButton.accessibilityLabel = AccessibilityLabelConstants.NearestAreaButton
        self.nearestAreaButton.accessibilityHint = nil
        self.nearestAreaButton.accessibilityTraits.remove(.button)
//        self.nearestAreaButton.accessibilityTraits.insert(.startsMediaSession)
        
        self.nearbyAreaButton.accessibilityLabel = AccessibilityLabelConstants.NearbyAreaButton
        self.nearbyAreaButton.accessibilityHint = nil

        self.soundSettingButton.accessibilityLabel = AccessibilityLabelConstants.SoundSettingButton
        self.soundSettingButton.accessibilityHint = nil

    }

    @IBAction func onclickNearestAreaButton(_ sender: UIButton) {
        print("onclickNearestAreaButton")
        
        self.viewModel.onclickNearestAreaButton(sender)
    }
    
    @IBAction func onclickNearbyAreaButton(_ sender: UIButton) {
        print("onclickNearbyAreaButton")
        self.viewModel.onclickNearbyAreaButton(sender)
        
    }
    
    @IBAction func onclickSoundSettingButton(_ sender: UIButton) {
        print("onclickSoundSettingButton")
        self.viewModel.onclickSoundSettingButton(sender)
        
    }

    
}
