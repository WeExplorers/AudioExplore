//
//  AudioPlayer.swift
//
//  Created by Evan Xie on 2019/12/18.
//

import AVFoundation
import QuartzCore

final class AudioPlayer: NSObject {
    
    enum Error: Swift.Error {
        case decodeError
    }
    
    /// 声音淡入淡出效果
    enum FadeMode {
        /// 无淡入淡出
        case none
        
        /// 淡入，开始播放的时候声音逐渐变大， 可以自定义义淡入时间
        case `in`(TimeInterval)
        
        /// 淡出，停止的时候声音逐渐变小
        case `out`(TimeInterval)
        
        /// 淡入淡出
        case inOut(TimeInterval)
        
        var duration: TimeInterval {
            switch self {
            case .none:
                return 0.0
            case .in(let time), .out(let time), .inOut(let time):
                return time
            }
        }
    }
    
    fileprivate var audioURL: URL
    fileprivate var player: AVAudioPlayer?
    fileprivate var delayPlayTimer: DispatchSourceTimer?
    fileprivate var delayStopTimer: DispatchSourceTimer?
    
    fileprivate var lock = MutexLock()
    fileprivate var fading = false
    fileprivate var isFading: Bool {
        lock.lock()
        let fading = self.fading
        lock.unlock()
        return fading
    }
    
    fileprivate var fadeInDuration: TimeInterval = 0
    fileprivate var fadeInStartTimestamp: TimeInterval?
    fileprivate var fadeInDisplayLink: CADisplayLink?

    fileprivate var fadeOutDuration: TimeInterval = 0
    fileprivate var fadeOutStartTimestamp: TimeInterval?
    fileprivate var fadeOutDisplayLink: CADisplayLink?
    
    let fadeMode: FadeMode
    var fadeInTimingFunction = CAMediaTimingFunction(name: .easeIn)
    var fadeOutTimingFunction = CAMediaTimingFunction(name: .easeOut)
    
    var onComletion: (() -> Void)? = nil
    var onError: ((AudioPlayer.Error) -> Void)? = nil
    
    /// 音频的播放音量, [0.0, 1.0]
    var volume: Float = 1.0
    
    init(audioURL: URL, fadeMode: FadeMode = .none)  {
        do {
            self.fadeMode = fadeMode
            self.audioURL = audioURL
            fadeInDuration = fadeMode.duration
            fadeOutDuration = fadeMode.duration
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
        super.init()
        player?.delegate = self
    }
    
    deinit {
        self.player?.delegate = nil
        self.player = nil
    }
    
    /// 播放音频
    func play() {
        guard let p = player, !p.isPlaying else { return }
        stopTimers()
        startFadeIn(p)
    }
    
    /// 延迟播放音频，单位：秒
    func play(delay: TimeInterval) {
        guard delay > 0.0 else {
            play()
            return
        }
        
        guard let p = player, !p.isPlaying else { return }
        
        let delayTimeStamp  = p.deviceCurrentTime + delay
        guard p.play(atTime: delayTimeStamp) else { return }
        startDelayTimerForPlay(delay)
    }
    
    /// Seek 到 `startTime` 时间位置开始播放，播放指定 `duration` 时长后停止.
    func play(startTime: TimeInterval, duration: TimeInterval) {
        guard let p = player else { return }
        if p.isPlaying {
            p.pause()
        }
        
        p.currentTime = startTime
        play()
        startDelayTimerForStop(duration)
    }
    
    /// 暂停音频播放
    func pause() {
        guard let p = player, p.isPlaying else { return }
        stopTimers()
        p.pause()
    }
    
    /// 停止音频播放
    func stop() {
        guard let p = player, p.isPlaying else { return }
        stopTimers()
        startFadeOut(p)
    }
    
    /// 跳到音频的指定时间。根据 seek 之间的播放状态来决定是否需要恢复播放
    func seek(to time: TimeInterval) {
        guard let p = player,
            p.currentTime != time,
            p.duration >= time else { return }
        
        if p.isPlaying {
            pause()
            p.currentTime = time
            play()
        } else {
            p.currentTime = time
        }
    }
}

fileprivate extension AudioPlayer {
    
    func stopTimers() {
        stopFadeIn()
        stopFadeOut()
        stopDelayTimerForPlay()
    }
    
    // MARK: - Fade In/Out
    
    func startFadeIn(_ player: AVAudioPlayer) {
        guard fadeMode.duration > 0.001 else {
            // 如果淡入时间为0， 就直接播放音频
            player.volume = volume
            player.play()
            return
        }
        
        player.volume = 0.0
        player.play()
        fadeInDisplayLink = CADisplayLink(target: self, selector: #selector(updateFadeIn))
        fadeInDisplayLink?.add(to: .main, forMode: .common)
    }
    
    func stopFadeIn() {
        fadeInDisplayLink?.invalidate()
        fadeInDisplayLink = nil
        fadeInStartTimestamp = nil
    }
    
    func startFadeOut(_ player: AVAudioPlayer) {
        guard fadeMode.duration > 0.001 else {
            // 如果淡出时间为0， 就直接停止音频
            player.volume = 0.0
            player.pause()
            player.stop()
            return
        }
        
        fadeOutDisplayLink = CADisplayLink(target: self, selector: #selector(updateFadeOut))
        fadeOutDisplayLink?.add(to: .main, forMode: .common)
    }
    
    func stopFadeOut() {
        fadeOutDisplayLink?.invalidate()
        fadeOutDisplayLink = nil
        fadeOutStartTimestamp = nil
    }
    
    func stopFading() {
        stopFadeIn()
        stopFadeOut()
    }
    
    @objc func updateFadeIn(_ link: CADisplayLink) {
        if fadeInStartTimestamp == nil {
            fadeInStartTimestamp = link.timestamp
        }
        
        let elapsed = link.timestamp - fadeInStartTimestamp!
        var progress = CGFloat(min(elapsed / fadeInDuration, 1.0))
        progress = fadeInTimingFunction.process(fractionComplete: progress, duration: fadeInDuration)
        player?.volume = volume * Float(progress)
        
        if progress >= 0.999 {
            stopFadeIn()
        }
    }
    
    @objc func updateFadeOut(_ link: CADisplayLink) {
        if fadeOutStartTimestamp == nil {
            fadeOutStartTimestamp = link.timestamp
        }
        
        let elapsed = link.timestamp - fadeOutStartTimestamp!
        var progress = CGFloat(min(elapsed / fadeOutDuration, 1.0))
        progress = fadeOutTimingFunction.process(fractionComplete: progress, duration: fadeOutDuration)
        player?.volume = volume - volume * Float(progress)
        
        if progress >= 0.999 {
            stopFadeOut()
            player?.pause()
            player?.stop()
        }
    }
    
    // MARK: - Delay Play
    
    func startDelayTimerForPlay(_ delay: TimeInterval) {
        stopDelayTimerForPlay()
        delayPlayTimer = DispatchSource.makeTimerSource()
        delayPlayTimer?.schedule(
            deadline: .now() + .milliseconds(Int(1000 * delay)),
            repeating: .never,
            leeway: .milliseconds(0)
        )
        delayPlayTimer?.setEventHandler(handler: { [weak self] in
            self?.stopDelayTimerForPlay()
            self?.play()
        })
        delayPlayTimer?.resume()
    }
    
    func stopDelayTimerForPlay() {
        guard let timer = delayPlayTimer, !timer.isCancelled else {
            return
        }
        timer.cancel()
        delayPlayTimer = nil
    }
    
    // MARK: - Delay Stop
    
    func startDelayTimerForStop(_ delay: TimeInterval) {
        stopDelayTimerForStop()
        delayStopTimer = DispatchSource.makeTimerSource()
        delayStopTimer?.schedule(
            deadline: .now() + .milliseconds(Int(1000 * delay)),
            repeating: .never,
            leeway: .milliseconds(0)
        )
        delayStopTimer?.setEventHandler(handler: { [weak self] in
            self?.stopDelayTimerForStop()
            self?.stop()
        })
        delayStopTimer?.resume()
    }
    
    func stopDelayTimerForStop() {
        guard let timer = delayStopTimer, !timer.isCancelled else {
            return
        }
        timer.cancel()
        delayStopTimer = nil
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimers()
        stopDelayTimerForStop()
        onComletion?()
    }
    
    private func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("音频解码失败: \(String(describing: error))")
        stopTimers()
        onError?(.decodeError)
    }
    
}
