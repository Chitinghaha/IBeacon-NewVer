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

    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var nearestAreaView: UIView!
    
    @IBOutlet weak var nearbyAreaView: UIView!
    
    @IBOutlet weak var soundSettingView: UIView!
    
    
    @IBOutlet weak var nearestAreaButton: UIButton!
    
    @IBOutlet weak var nearbyAreaButton: UIButton!
    
    @IBOutlet weak var soundSettingButton: UIButton!
    
    
    @IBAction func onclickNearestAreaButton(_ sender: Any) {
        print("onclickNearestAreaButton")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            if let ibeacon = self.nearestiBeacon {
                UIAccessibility.post(notification: .announcement, argument: ibeacon.name + ibeacon.description)

//                AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.name)
//                AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.description)
            }
            else {
                UIAccessibility.post(notification: .announcement, argument: "無法取得最近的ibeacon資料")

            }
        }

    }
    
    @IBAction func onclickNearbyAreaButton(_ sender: Any) {
        print("onclickNearbyAreaButton")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            if (self.rangingiBeacons.count > 0) {
                self.rangingiBeacons.forEach {
                    UIAccessibility.post(notification: .announcement, argument: $0.name + $0.description)
                    //                UIAccessibility.post(notification: .pauseAssistiveTechnology, argument: nil)
                    
                    //                AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.name)
                    //                AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.description)
                }
            }
            else {
                UIAccessibility.post(notification: .announcement, argument: "無法取得附近的ibeacon資料")
            }
        }
    }
    
    @IBAction func onclickSoundSettingButton(_ sender: Any) {
        print("onclickSoundSettingButton")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.8) {
            AVSpeechSynthesizerService.shared.continuouslySpeak(content: "功能測試")

        }
//        let vc = SoundSettingViewController(nibName: "SoundSettingViewController", bundle: nil)
//
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Member var
    let locationManager = CLLocationManager()
    var rangingiBeacons: [iBeaconModel] = []
    
    var nearestiBeaconFilterContainer: [Int] = []
    
    @Published var nearestiBeacon: iBeaconModel? = nil
    
    var speechWhenClosing = PassthroughSubject<String, Never>()
    var isDistanceImmediately = PassthroughSubject<Bool, Never>()
    
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setAccessibiluty()
        
        self.setupBinding()
//        self.testBinding()
        self.setupLocationManager()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
        
    func testBinding() {
        let speechTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .map { _ in "測試靠近某物" }
            
        speechTimer
            .print("speechTimer")
            .sink { string in
                self.speechWhenClosing.send(string)
            }
            .store(in: &cancellable)
        
        Timer.publish(every: 2.3, on: .current, in: .common)
            .autoconnect()
            .map { _ in Bool.random() }
            .sink {
                self.isDistanceImmediately.send($0)
            }
            .store(in: &cancellable)
        
    }
    
    func setupLocationManager() {
        self.locationManager.delegate = self
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            print("Beacon監控是可用的")
            locationManager.requestAlwaysAuthorization()
            
            let ibeacons = iBeaconViewModel.shared.ibeacons
            
            
            ibeacons.forEach {
                let constraint = CLBeaconIdentityConstraint(uuid: $0.uuid)
                
                if (!self.locationManager.rangedBeaconConstraints.contains(constraint)) {
                    self.locationManager.startRangingBeacons(satisfying: constraint)
                }
            }
        }else {
            print("Beacon監控不可用")
        }
    }

    func setAccessibiluty() {
        self.testLabel.isAccessibilityElement = false
        
        self.nearestAreaButton.accessibilityLabel = AccessibilityConstants.NearestAreaButton
        self.nearestAreaButton.accessibilityHint = nil
        
        self.nearbyAreaButton.accessibilityLabel = AccessibilityConstants.NearbyAreaButton
        self.nearbyAreaButton.accessibilityHint = nil

        self.soundSettingButton.accessibilityLabel = AccessibilityConstants.SoundSettingButton
        self.soundSettingButton.accessibilityHint = nil

    }
    
}

extension HomePageViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager did fail: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Location manager monitoring did fail: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        var constraint: CLBeaconIdentityConstraint
        
        constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
//        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid, major: CLBeaconMajorValue(region.major), minor: CLBeaconMinorValue(region.minor))
        
        AudioPlayerService.shared.playSound(name: SoundEffectConstant.start)
        guard CLLocationManager.isRangingAvailable() else { return }
        print("進入範圍，開始監測距離：\(constraint)")
        if (!manager.rangedBeaconConstraints.contains(constraint)) {
            manager.startRangingBeacons(satisfying: constraint)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        guard region is CLBeaconRegion,
//        let region = region as? CLBeaconRegion,
//        let major = region.major,
//        let minor = region.minor
//        else { return }
//
//        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid, major: CLBeaconMajorValue(truncating: major), minor: CLBeaconMinorValue(truncating: minor))
//        print("離開範圍，解除監測距離:\(region)")
//
//        guard CLLocationManager.isRangingAvailable() else { return }
//
//        manager.stopRangingBeacons(satisfying: constraint)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 開始偵測範圍之後，就先檢查目前的 state 是否在範圍內
        manager.requestState(for: region)
        print("didStartMonitoringFor:\(region)")
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        var constraint: CLBeaconIdentityConstraint
        guard CLLocationManager.isRangingAvailable() else { return }

        print("state of region:\(region) = \(state)")
        constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
        if state == .inside { // 在範圍內
            if (!manager.rangedBeaconConstraints.contains(constraint)) {
                manager.startRangingBeacons(satisfying: constraint)
            }
        }
//
//        if let major = region.major,
//           let minor = region.minor {
//            constraint = CLBeaconIdentityConstraint(uuid: region.uuid, major: CLBeaconMajorValue(truncating: major), minor: CLBeaconMinorValue(truncating: minor))
//            print("開始監控範圍 startRangingBeacons, constraint=\(constraint)")
//            if state == .inside { // 在範圍內
//                manager.startRangingBeacons(satisfying: constraint)
//            } else if state == .outside { // 在範圍外
//                manager.stopRangingBeacons(satisfying: constraint)
//            }
//
//        }
//        else {
//            constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
//            if state == .inside { // 在範圍內
//                manager.startRangingBeacons(satisfying: constraint)
//
//            }
//        }
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location manager ranging beacons did fail: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // beacons 是一個 array，裡頭的 beacon 由近到遠排序
        self.rangingiBeacons = beacons.compactMap {
            iBeaconViewModel.shared.transformToiBeaconModel(from: $0)
        }
        
        print("beacons:")
        beacons.forEach {
            print($0)
        }
        
        // 取出最近且不是-1m的ibeacon id 存入filter pool中
        if let clBeacon = beacons.first(where: { $0.accuracy > 0 }),
            let ibeacon = iBeaconViewModel.shared.transformToiBeaconModel(from: clBeacon) {
            self.nearestiBeaconFilterContainer.append(ibeacon.id)
        }
        else {
            self.nearestiBeaconFilterContainer.append(-1)
        }
        
        
        if (self.nearestiBeaconFilterContainer.count > AppSetting.nearestFilterNum) {
            self.nearestiBeaconFilterContainer.removeFirst()
        }
        
        if (self.nearestiBeaconFilterContainer.last! != -1 &&
            self.nearestiBeaconFilterContainer.first! != self.nearestiBeaconFilterContainer.last! &&
            self.nearestiBeaconFilterContainer.count > 2) {
            self.nearestiBeaconFilterContainer.removeFirst(2)
        }
        

        if (self.nearestiBeaconFilterContainer.count > AppSetting.nearestFilterNum / 3) {
            let idFrequency = self.nearestiBeaconFilterContainer.reduce(into: [:]) {
                counts, id in
                counts[id, default: 0] += 1
            }
            print("pool =\(idFrequency)")
            if let nearestiBeaconID = idFrequency.max(by: { $0.value < $1.value })?.key {
                if (nearestiBeaconID == -1) {
                    self.nearestiBeacon = nil
                }
                else {
                    self.nearestiBeacon = self.rangingiBeacons.first{ $0.id == nearestiBeaconID }
                }
            }
        }
    }
}

extension HomePageViewController {
    func setupBinding() {
        self.$nearestiBeacon
            .receive(on: RunLoop.main)
            .sink { beacon in
//                print("nearestiBeacon received: \(beacon)")
                if let beacon = beacon {

                    self.testLabel.text = "最近的物體:\(beacon.name)\n\(beacon.description)\n"
                    
                    // 加上距離的publish,去過濾掉已經遠離原本目標的情況
                    if (beacon.proximity == 1) {
                        self.speechWhenClosing.send("\(beacon.name)，\(beacon.description)")
                        self.isDistanceImmediately.send(true)
                    }
                    else {
                        self.isDistanceImmediately.send(false)
                    }
                    
                    switch beacon.proximity {
                    case 1:
                        self.testLabel.text! += "距離極近"
                    case 2:
                        self.testLabel.text! += "距離中等"
                    case 3:
                        self.testLabel.text! += "距離遠"
                    default:
                        self.testLabel.text! += "距離未知"
                    }
                }
                else {
                    self.testLabel.text = "搜尋中..."
                }
            }
            .store(in: &self.cancellable)
        
        self.speechWhenClosing.combineLatest(self.isDistanceImmediately)
            .filter { $0.0.count != 0 }
            .throttle(for: .seconds(AppSetting.speechInterval), scheduler: RunLoop.main, latest: true)
            .print("speechWhenClosing throttle")
            .sink { content, isDistanceImmediately in
                if (isDistanceImmediately) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        UIAccessibility.post(notification: .announcement, argument: content)
                    }
                }
            }
            .store(in: &cancellable)
    }

}
