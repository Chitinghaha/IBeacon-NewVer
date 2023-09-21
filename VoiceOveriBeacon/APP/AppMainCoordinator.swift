//
//  AppMainCoordinator.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/19.
//

import Foundation
import UIKit

class AppMainCoordinator {

    var navigationController: UINavigationController
    
    private let window: UIWindow

    init(navigationController: UINavigationController, window: UIWindow) {
        self.navigationController = navigationController
        self.window = window
        
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
    }
    
    func start() {
        self.gotoEntryPointSearchingPage()
    }
    
    func gotoEntryPointSearchingPage() {
        
        if let oldSearchingVC = self.navigationController.viewControllers.first(where: {
            $0.nibName == "EntryPointSearchViewController"
        }) {
            self.navigationController.popToViewController(oldSearchingVC, animated: false)
        }
        else {
            iBeaconViewModel.shared.coordinator = self
            
            let searchingVC = EntryPointSearchViewController(viewModel: iBeaconViewModel.shared)
            
            self.navigationController.pushViewController(searchingVC, animated: false)
        }
    }
    
    func gotoPathNavigatingPage(with desitinationiBeacon: iBeaconModel) {
        let pathNavigationVC = PathNavigatingViewController(viewModel: iBeaconViewModel.shared, destinationiBeacon: desitinationiBeacon)
        
        self.navigationController.pushViewController(pathNavigationVC, animated: true)

    }
}

