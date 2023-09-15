//
//  AudioPlayerService.swift
//  TactileMap
//
//  Created by 陳邦亢 on 2023/8/31.
//

import AVFoundation
import UIKit
import Combine

class AudioPlayerService {
    
    static let shared = AudioPlayerService()
    
    private var audioPlayer: AVAudioPlayer?
    
    private var cancellable = Set<AnyCancellable>()
    
    private let playContent = PassthroughSubject<String, Never>()
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        self.playContent
            .removeDuplicates()
            .sink { name in
                self.audioPlayer?.stop()
                
                if (name.count == 0) { return }
                
                if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                        self.audioPlayer?.numberOfLoops = -1
                        self.audioPlayer?.play()
                        print("Audio file found. Playing the sound.")
                    } catch {
                        print("Error in AVAudioPlayer: \(error)")
                    }
                }
                else {
                    guard let audioData = NSDataAsset(name: name)?.data else {
                        print("Error: sound file with name \(name) not found")
                        return
                    }
                    
                    do {
                        self.audioPlayer = try AVAudioPlayer(data: audioData)
                        self.audioPlayer?.numberOfLoops = -1
                        self.audioPlayer?.play()
                        print("Audio file found. Playing the sound.")
                    } catch {
                        print("Error in AVAudioPlayer: \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    func playSound(name: String) {
        
        if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                self.audioPlayer?.play()
            } catch {
                // 處理錯誤
                print("Error in AVAudioPlayer: \(error.localizedDescription)")
            }
        }
        else {
            guard let audioData = NSDataAsset(name: name)?.data else {
                print("Error: sound file with name \(name) not found")
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(data: audioData)
                self.audioPlayer?.play()
                print("Audio file found. Playing the sound.")
            } catch {
                print("Error in AVAudioPlayer: \(error.localizedDescription)")
            }
        }
    }
    
    func playLoopSound(name: String) {
        self.playContent.send(name)
//        self.audioPlayer?.stop()
//
//        if let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") {
//            do {
//                self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
//                self.audioPlayer?.numberOfLoops = -1
//                self.audioPlayer?.play()
//                print("Audio file found. Playing the sound.")
//            } catch {
//                print("Error in AVAudioPlayer: \(error)")
//            }
//        }
//        else {
//            guard let audioData = NSDataAsset(name: name)?.data else {
//                print("Error: sound file with name \(name) not found")
//                return
//            }
//
//            do {
//                self.audioPlayer = try AVAudioPlayer(data: audioData)
//                self.audioPlayer?.numberOfLoops = -1
//                self.audioPlayer?.play()
//                print("Audio file found. Playing the sound.")
//            } catch {
//                print("Error in AVAudioPlayer: \(error.localizedDescription)")
//            }
//        }
    }
    
    func stopSound() {
        self.playContent.send("")
        print("Audio player stopped.")
    }
    
}



