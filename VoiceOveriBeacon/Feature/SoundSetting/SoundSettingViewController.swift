//
//  SoundSettingViewController.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/2.
//

import UIKit

class SoundSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }

    @IBAction func onclickCancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onclickEnterAreaSwitch(_ sender: Any) {
    }
    
    
    @IBAction func onclickCloseDistanceSwitch(_ sender: Any) {
    }
    
    
    @IBAction func onclickSaveButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
