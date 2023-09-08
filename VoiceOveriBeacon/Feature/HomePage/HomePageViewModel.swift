//
//  HomePageViewModel.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/8.
//

import Foundation
import Combine
import UIKit
import UIKit.UIAccessibility

class HomePageViewModel {
    
    var rangingiBeacons: [iBeaconModel] = []
    var nearestiBeacon: iBeaconModel? = nil
    
    private var cancellables = Set<AnyCancellable>()

    init () {
        self.setupBinding()
    }
    
    func setupBinding() {
        iBeaconService.shared.$rangingiBeacons
            .sink {
                self.rangingiBeacons = $0
            }
            .store(in: &cancellables)
        
        iBeaconService.shared.$nearestiBeacon
            .sink {
                self.nearestiBeacon = $0
            }
            .store(in: &cancellables)
    }
    
    func onclickNearestAreaButton(_ sender: UIButton) {
        if let ibeacon = self.nearestiBeacon {
            UIAccessibility.post(notification: .announcement, argument: ibeacon.description)

//
//            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//                AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.name)
//                AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.description)
//            }
        }
        else {
            UIAccessibility.post(notification: .announcement, argument: "無法取得最近的ibeacon資料")
            UIAccessibility.post(notification: .screenChanged, argument: nil)


//            AVSpeechSynthesizerService.shared.continuouslySpeak(content: "無法取得最近的ibeacon資料")
        }
    }
    
    func onclickNearbyAreaButton(_ sender: UIButton) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            if (self.rangingiBeacons.count > 0) {
                self.rangingiBeacons.forEach {
                    AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.name)
                    AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.description)
                }
            }
            else {
                AVSpeechSynthesizerService.shared.continuouslySpeak(content: "無法取得附近ibeacon資料")
            }
        }
    }
    
    func onclickSoundSettingButton(_ sender: UIButton) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            AVSpeechSynthesizerService.shared.continuouslySpeak(content: "尚未開放此功能")
        }
        
        
//        let vc = SoundSettingViewController(nibName: "SoundSettingViewController", bundle: nil)
//
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}
