//
//  PathNavigatingViewController.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/19.
//

import UIKit
import Combine

class PathNavigatingViewController: UIViewController {
    // MARK: IBOutlets
    
    @IBOutlet weak var destinationNameLabel: UILabel!
    
    @IBOutlet weak var nearestiBeaconInfoLabel: UILabel!
    
    @IBAction func onclickCancelNavigateButton(_ sender: UIButton) {
        AudioPlayerService.shared.stopSound()
        self.viewModel.cancelNavigating()
    }
    
    // MARK: members
    private var cancellable = Set<AnyCancellable>()
    
    var speechWhenClosing = PassthroughSubject<String, Never>()
    var isDistanceImmediately = PassthroughSubject<Bool, Never>()

    var viewModel: iBeaconViewModel
    
    var destinationiBeacon: iBeaconModel
    
    init(viewModel: iBeaconViewModel, destinationiBeacon: iBeaconModel) {
        self.viewModel = viewModel
        self.destinationiBeacon = destinationiBeacon
        super.init(nibName: String(describing: Self.self), bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setupBinding()
    }

    func initView() {
        self.navigationController?.isNavigationBarHidden = true
        self.destinationNameLabel.text = "目的地\n" + self.destinationiBeacon.name
    }
    
    func setupBinding() {
        self.viewModel.$nearestiBeacon
            .receive(on: RunLoop.main)
            .sink { [weak self] beacon in
                guard let self = self else { return }
                if let beacon = beacon {
                    //處理已抵達目的地
                    if (beacon.name == self.destinationiBeacon.name && beacon.proximity == 1) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            UIAccessibility.post(notification: .announcement, argument: "已抵達目的地:\(beacon.name)")
                        }
                        AudioPlayerService.shared.stopSound()
                        AudioPlayerService.shared.playSound(name: SoundEffectConstant.finishNavigating)
                        self.cancellable.removeAll(keepingCapacity: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            self.viewModel.finishNavigating()
                        }
                        return
                    }
                    
                    // 處理目的地相關路徑描述
                    var description: String = beacon.description
                    if let intersectionInfo = beacon.intersectionInfo,
                       let matchingNode = intersectionInfo.first(where: { $0.nodeID == self.destinationiBeacon.id }) {
                        
                        description = matchingNode.description
                    }
                    
                    // 加上距離的publisher,去過濾掉已經遠離原本目標的情況
                    self.isDistanceImmediately.send(false)
                    
                    self.nearestiBeaconInfoLabel.text = "最近的物體:\(beacon.name)\n\(description)\n"
                    
                    switch beacon.proximity {
                    case 1:
                        self.nearestiBeaconInfoLabel.text! += "距離極近"
                        AudioPlayerService.shared.playLoopSound(name: SoundEffectConstant.beaconImmediately)
                        self.speechWhenClosing.send("\(beacon.name)，\(description)")
                        self.isDistanceImmediately.send(true)
                    case 2:
                        self.nearestiBeaconInfoLabel.text! += "距離中等"
                        AudioPlayerService.shared.playLoopSound(name: SoundEffectConstant.beaconNear)
                    case 3:
                        self.nearestiBeaconInfoLabel.text! += "距離遠"
                        AudioPlayerService.shared.stopSound()
                    default:
                        self.nearestiBeaconInfoLabel.text! += "距離未知"
                    }
                }
                else {
                    AudioPlayerService.shared.stopSound()
                    self.nearestiBeaconInfoLabel.text = "搜尋中..."
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
