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
    
    let locationManager = CLLocationManager()
    var rangingiBeacons: [iBeaconModel] = []
    var nearestiBeacon: iBeaconModel? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setAccessibiluty()
        
        self.setupLocationManager()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupLocationManager() {
        self.locationManager.delegate = self
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            print("Beacon監控是可用的")
            locationManager.requestAlwaysAuthorization()
            
            let ibeacons = iBeaconViewModel.shared.ibeacons
            
            ibeacons.forEach {
                let region = CLBeaconRegion(beaconIdentityConstraint: CLBeaconIdentityConstraint(uuid: $0.uuid, major: CLBeaconMajorValue($0.major), minor: CLBeaconMinorValue($0.minor)), identifier: $0.uuidString)

                self.locationManager.startMonitoring(for: region)
            }
        }else {
            print("Beacon監控不可用")
        }
    }

    func setAccessibiluty() {
        self.nearestAreaButton.accessibilityLabel = AccessibilityConstants.NearestAreaButton
        self.nearestAreaButton.accessibilityHint = nil
        
        self.nearbyAreaButton.accessibilityLabel = AccessibilityConstants.NearbyAreaButton
        self.nearbyAreaButton.accessibilityHint = nil

        self.soundSettingButton.accessibilityLabel = AccessibilityConstants.SoundSettingButton
        self.soundSettingButton.accessibilityHint = nil

    }

    @IBAction func onclickNearestAreaButton(_ sender: Any) {
        print("onclickNearestAreaButton")
        
        if let ibeacon = self.nearestiBeacon {
            AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.name)
            AVSpeechSynthesizerService.shared.continuouslySpeak(content: ibeacon.description)
        }

    }
    
    @IBAction func onclickNearbyAreaButton(_ sender: Any) {
        print("onclickNearbyAreaButton")
        
        self.rangingiBeacons.forEach {
            AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.name)
            AVSpeechSynthesizerService.shared.continuouslySpeak(content: $0.description)
        }
    }
    
    @IBAction func onclickSoundSettingButton(_ sender: Any) {
        print("onclickSoundSettingButton")
//        let vc = SoundSettingViewController(nibName: "SoundSettingViewController", bundle: nil)
//        
//        self.navigationController?.pushViewController(vc, animated: true)
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
        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
        
        AudioPlayerService.shared.playSound(name: SoundEffectConstant.start)
        // 在這裡做一些進入 region 的處理，例如提供一些提示
        guard CLLocationManager.isRangingAvailable() else { return }
        // 既然進入 region 了，那就偵測跟裝置的距離
        manager.startRangingBeacons(satisfying: constraint)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid)

        // 在這裡做一些離開 region 的處理，例如提供一些提示
        guard CLLocationManager.isRangingAvailable() else { return }
        // 既然離開 region 了，那就停止偵測跟裝置的距離
        manager.stopRangingBeacons(satisfying: constraint)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 開始偵測範圍之後，就先檢查目前的 state 是否在範圍內
        manager.requestState(for: region)
        print("didStartMonitoringFor:\(region)")
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid)

        if state == .inside { // 在範圍內
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(satisfying: constraint)
            }
        } else if state == .outside { // 在範圍外
            if CLLocationManager.isRangingAvailable() {
                manager.stopRangingBeacons(satisfying: constraint)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location manager ranging beacons did fail: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // beacons 是一個 array，裡頭的 beacon 由近到遠排序
//        print("beacons:\(beacons)")
        
        var i = 0
        
        while (i < self.rangingiBeacons.count) {
            if (!beacons.contains(where: { iBeaconViewModel.shared.transformToiBeaconModel(from: $0) == self.rangingiBeacons[i] })) {
                self.rangingiBeacons.remove(at: i)
                i -= 1
            }
            i += 1
        }

        beacons.forEach { beacon in
            guard let ibeacon = iBeaconViewModel.shared.transformToiBeaconModel(from: beacon)
            else { return }
            if (!self.rangingiBeacons.contains(where: { $0 == ibeacon })) {
                self.rangingiBeacons.append(ibeacon)
            }
        }
        
        if let beacon = beacons.first {
            // 取得距離最近的 beacon 了，作些事情吧
            self.nearestiBeacon = iBeaconViewModel.shared.transformToiBeaconModel(from: beacon)
        }
    }
}
