//
//  AudioEngine.swift
//
//  Created by Evan Xie on 2019/12/13.
//

import AVFoundation
import AudioToolbox

/// 音频片断时间区域
enum AudioRange {
    /// 整个音频， 从开始 0 秒 到结束
    case full
    
    /// 音频指定时间区域，由开始时间和时长来决定
    case range(startTime: TimeInterval, duration: TimeInterval)
}

/// App 音效播放引擎
final class AudioEngine {
    
    static let shared = AudioEngine()
    
    fileprivate var soundPlayer: AudioPlayer?
    fileprivate var ambientPlayer: AudioPlayer?
    
    var audioCategory: AVAudioSession.Category = .soloAmbient {
        didSet { configAudioSession() }
    }
    
    /// 是否静音
    var shouldMute: Bool = false
    
    init() {
        configAudioSession()
    }

    /// 播放音效。
    func playSoundEffect(_ soundEffectFileURL: URL?,
                         volume: Float = 1.0,
                         range: AudioRange = .full,
                         fadeMode: AudioPlayer.FadeMode = .none) {
        
        guard !shouldMute else { return }
        guard let fileURL = soundEffectFileURL, fileURL.isFileURL else {
            print("soundFileURL must be a file url.")
            return
        }
        
        stopSoundPlayer()
        soundPlayer = AudioPlayer(audioURL: fileURL, fadeMode: fadeMode)
        soundPlayer?.volume = volume
        
        switch range {
        case .full:
            soundPlayer?.play()
        case let .range(startTime: start, duration: duration):
            soundPlayer?.play(startTime: start, duration: duration)
        }
    }
    
    /// 停止播放音效
    func stopSoundPlayer() {
        soundPlayer?.stop()
        soundPlayer = nil
    }
    
    /// 播放环境声。
    func playAmbientSound(_ ambientSoundFileURL: URL?, volume: Float = 0.5) {
        guard !shouldMute else { return }
        guard let fileURL = ambientSoundFileURL, fileURL.isFileURL else {
            print("ambientSoundFileURL must be a file url.")
            return
        }
        
        stopAmbientSound()
        ambientPlayer = AudioPlayer(audioURL: fileURL, fadeMode: .inOut(0.8))
        ambientPlayer?.volume = volume
        ambientPlayer?.play()
    }
    
    /// 停止播放环境音
    func stopAmbientSound() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }
    
    /// 停止所有声音播放
    func stopAll() {
        stopSoundPlayer()
        stopAmbientSound()
    }
}

fileprivate extension AudioEngine {
    
    func configAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(audioCategory)
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
    }
}
