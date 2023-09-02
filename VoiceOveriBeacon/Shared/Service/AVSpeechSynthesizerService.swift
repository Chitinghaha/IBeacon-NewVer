//
//  AVSpeechSynthesizerService.swift
//  TactileMap
//
//  Created by 陳邦亢 on 2023/8/30.
//

import Foundation
import AVFoundation

class AVSpeechSynthesizerService: NSObject {
    static let shared = AVSpeechSynthesizerService()
    let synthesizer = AVSpeechSynthesizer()
    
    var utterancesInQueues: [AVSpeechUtterance] = []
    
    override init() {
        super.init()
        
        self.synthesizer.delegate = self
    }
    
    func stop() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    func speak(content: String) {
        if (self.utterancesInQueues.count > 0) {
            print("執行佇列中")
            self.continuouslySpeak(content: content)
            return
        }
        
        if self.synthesizer.isSpeaking {
            self.synthesizer.stopSpeaking(at: .immediate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let utterance = AVSpeechUtterance(string: content)
                utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
                utterance.volume = 1.0
                self.synthesizer.speak(utterance)
            }
        } else {
            let utterance = AVSpeechUtterance(string: content)
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
            utterance.volume = 1.0
            self.synthesizer.speak(utterance)
        }
    }
    
    func continuouslySpeak(content: String) {
        let utterance = AVSpeechUtterance(string: content)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        utterance.volume = 1.0 
        self.utterancesInQueues.append(utterance)
        if (self.utterancesInQueues.count == 1) {
            self.speakNextUtterance()
        }
    }
    
    func speakNextUtterance() {
        if let nextUtterance = self.utterancesInQueues.first,
           !self.synthesizer.isSpeaking {
            self.synthesizer.speak(nextUtterance)
        }
    }
}

extension AVSpeechSynthesizerService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Remove the finished utterance from the array
        if let index = self.utterancesInQueues.firstIndex(of: utterance) {
            self.utterancesInQueues.remove(at: index)
        }
        
        // Speak the next utterance
        speakNextUtterance()
    }
}
