//
//  EntryPointSearchViewController.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/19.
//

import UIKit
import Combine

class EntryPointSearchViewController: UIViewController {
    private var cancellable = Set<AnyCancellable>()
    
    var viewModel: iBeaconViewModel
    
    var isShowingPicker = false
    
    init(viewModel: iBeaconViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: Self.self), bundle: nil)
        
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initView()
        self.setupBinging()
    }

    func initView() {
        self.navigationController?.isNavigationBarHidden = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
//        AudioPlayerService.shared.playLoopSound(name: SoundEffectConstant.searching)
        self.isShowingPicker = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        AudioPlayerService.shared.stopSound()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func entryPointFoundProcess() {
        if (!self.isShowingPicker) {
            self.isShowingPicker = true
//            AudioPlayerService.shared.stopSound()
            
            let picker = FilterSearchPicker()
            
            picker.config = AccessibilitySearchFilterPickerConfiguration()
            
            picker.contentStrings = self.viewModel.predefinediBeacons.compactMap {
                if let canBeDestination = $0.canBeDestination,
                   canBeDestination {
                    return $0.name
                }
                else {
                    return nil
                }
            }
            
            picker.receiveResultString = { result in
                print(result)
                self.viewModel.updateCurrentDestination(with: result)
            }
            picker.searchTitle = "選擇目的地"
            picker.isSearchViewHidden = true
            picker.isCancelButtonHidden = true
            
            picker.show(on: self)
        }
    }
}

extension EntryPointSearchViewController {
    func setupBinging() {
        self.viewModel.$nearestiBeacon
            .receive(on: RunLoop.main)
            .compactMap{ $0 }
            .filter { $0.proximity == 1 }
            .print("filter receive nearestiBeacon")
            .sink { [weak self] beacon in
                guard let self = self else { return }
                if (beacon.minor == 1 || beacon.name == "入口") {
                    self.entryPointFoundProcess()
                }
            }
            .store(in: &self.cancellable)

    }
}
