//
//  ViewController.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/1.
//

import UIKit
import CoreLocation
import Combine

class HomePageViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var nearestAreaView: UIView!
    
    @IBOutlet weak var nearbyAreaView: UIView!
    
    @IBOutlet weak var soundSettingView: UIView!
    
    
    @IBOutlet weak var nearestAreaButton: UIButton!
    
    @IBOutlet weak var nearbyAreaButton: UIButton!
    
    @IBOutlet weak var soundSettingButton: UIButton!
    
    
    @IBAction func onclickNearestAreaButton(_ sender: Any) {
//        print("onclickNearestAreaButton")
//
//        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
//            if let ibeacon = self.nearestiBeacon {
//                UIAccessibility.post(notification: .announcement, argument: ibeacon.name + ibeacon.description)
//
////                AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.name)
////                AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.description)
//            }
//            else {
//                UIAccessibility.post(notification: .announcement, argument: "無法取得最近的ibeacon資料")
//
//            }
//        }
//
    }
    
    @IBAction func onclickNearbyAreaButton(_ sender: Any) {
//        print("onclickNearbyAreaButton")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//
//            if (self.rangingiBeacons.count > 0) {
//                self.rangingiBeacons.forEach {
//                    UIAccessibility.post(notification: .announcement, argument: $0.name + $0.description)
//                    //                UIAccessibility.post(notification: .pauseAssistiveTechnology, argument: nil)
//
//                    //                AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.name)
//                    //                AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.description)
//                }
//            }
//            else {
//                UIAccessibility.post(notification: .announcement, argument: "無法取得附近的ibeacon資料")
//            }
//        }
    }
    
    @IBAction func onclickSoundSettingButton(_ sender: Any) {
//        print("onclickSoundSettingButton")
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1.8) {
//            AVSpeechSynthesizerService.shared.continuouslySpeak(content: "功能測試")
//
//        }
////        let vc = SoundSettingViewController(nibName: "SoundSettingViewController", bundle: nil)
////
////        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Member var
    private var cancellable = Set<AnyCancellable>()
    
    private var viewModel: iBeaconViewModel = iBeaconViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupAccessibility()
        
        self.setupBinding()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
        
    func setupAccessibility() {
//        self.testLabel.isAccessibilityElement = false
        
        self.nearestAreaButton.accessibilityLabel = AccessibilityConstants.NearestAreaButton
        self.nearestAreaButton.accessibilityHint = nil
        
        self.nearbyAreaButton.accessibilityLabel = AccessibilityConstants.NearbyAreaButton
        self.nearbyAreaButton.accessibilityHint = nil

        self.soundSettingButton.accessibilityLabel = AccessibilityConstants.SoundSettingButton
        self.soundSettingButton.accessibilityHint = nil

    }
}

extension HomePageViewController {
    func setupBinding() {
        self.viewModel.$nearestiBeacon
            .receive(on: RunLoop.main)
            .sink { beacon in
                if let beacon = beacon {
                    self.testLabel.text = "最近的物體:\(beacon.name)\n\(beacon.description)\n"
                    
                    switch beacon.proximity {
                    case 1:
                        self.testLabel.text! += "距離極近"
                        AudioPlayerService.shared.playLoopSound(name: SoundEffectConstant.beaconImmediately)
                    case 2:
                        self.testLabel.text! += "距離中等"
                        AudioPlayerService.shared.playLoopSound(name: SoundEffectConstant.beaconNear)
                    case 3:
                        self.testLabel.text! += "距離遠"
                        AudioPlayerService.shared.stopSound()
                    default:
                        self.testLabel.text! += "距離未知"
                    }
                }
                else {
                    self.testLabel.text = "搜尋中..."
                }
            }
            .store(in: &self.cancellable)
        
//        self.viewModel.speechWhenClosing.combineLatest(self.viewModel.isDistanceImmediately)
//            .filter { $0.0.count != 0 }
//            .throttle(for: .seconds(AppSetting.speechInterval), scheduler: RunLoop.main, latest: true)
//            .print("speechWhenClosing throttle")
//            .sink { content, isDistanceImmediately in
//                if (isDistanceImmediately) {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        UIAccessibility.post(notification: .announcement, argument: content)
//                    }
//                }
//            }
//            .store(in: &cancellable)
    }

}
