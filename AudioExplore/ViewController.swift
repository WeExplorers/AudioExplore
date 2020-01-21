//
//  ViewController.swift
//  AudioExplore
//
//  Created by Evan Xie on 2019/12/17.
//  Copyright © 2019 Evan Xie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioEngine.shared.audioCategory = .soloAmbient
    }
    
    @IBAction func playSound(_ sender: Any) {
        let soundURL = Bundle.main.url(forResource: "E5", withExtension: "aac")
        AudioEngine.shared.playSoundEffect(soundURL, fadeMode: .inOut(0.8))
    }
    
    @IBAction func playBackgroundMusic(_ sender: Any) {
        let soundURL = Bundle.main.url(forResource: "bird", withExtension: "aac")
        let ambientURL = Bundle.main.url(forResource: "background", withExtension: "aac")
        AudioEngine.shared.playSoundEffect(soundURL, fadeMode: .inOut(0.5))
        AudioEngine.shared.playAmbientSound(ambientURL)
    }
    
    @IBAction func playM4a(_ sender: Any) {
        let soundURL = Bundle.main.url(forResource: "KenBurns", withExtension: "m4a")
        let ambientURL = Bundle.main.url(forResource: "Origami", withExtension: "m4a")
        AudioEngine.shared.playSoundEffect(soundURL, volume: 0.3, fadeMode: .inOut(0.5))
        AudioEngine.shared.playAmbientSound(ambientURL)
    }
}

