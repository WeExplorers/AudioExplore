//
//  TimingFuncational.swift
//  AnimationEngine
//
//  Created by Evan Xie on 2019/11/21.
//

import Foundation
import CoreGraphics

public typealias Metric = CGFloat

public protocol TimingFuncational {
    
    /// 根据 TimingFunction 来处理数值。
    /// - Parameter fractionComplete: 当前完成的进度, [0.0, 1.0].
    /// - Parameter duration: 动画时长, 用于提高处理数值的精确度。
    func process(fractionComplete: Metric, duration: TimeInterval) -> Metric
}
