//
//  CAMediaTimingFunctionExtension.swift
//  AnimationEngine
//
//  Created by Evan Xie on 2018/5/15.
//

import QuartzCore

/**
 Easing functions with control points. For details, please read the refernce below:
 http://easings.net/nl
 http://gizma.com/easing
 */
extension CAMediaTimingFunction {
    
    // MARK: - OS Provided
    public static let `default`  = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
    public static let linear = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    public static let easeIn = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    public static let easeOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    public static let easeInOut = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
    // MARK: - More 
    public static let easeInSine = CAMediaTimingFunction(controlPoints: 0.47, 0, 0.745, 0.715)
    public static let easeOutSine = CAMediaTimingFunction(controlPoints: 0.39, 0.575, 0.565, 1)
    public static let easeInOutSine = CAMediaTimingFunction(controlPoints: 0.445, 0.05, 0.55, 0.95)
    
    public static let easeInQuad = CAMediaTimingFunction(controlPoints: 0.55, 0.085, 0.68, 0.53)
    public static let easeOutQuad = CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)
    public static let easeInOutQuad = CAMediaTimingFunction(controlPoints: 0.455, 0.03, 0.515, 0.955)
    
    public static let easeInCubic = CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)
    public static let easeOutCubic = CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)
    public static let easeInOutCubic = CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)
    
    public static let easeInQuart = CAMediaTimingFunction(controlPoints: 0.895, 0.03, 0.685, 0.22)
    public static let easeOutQuart = CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)
    public static let easeInOutQuart = CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)
    
    public static let easeInQuint = CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)
    public static let easeOutQuint = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
    public static let easeInOutQuint = CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)
    
    public static let easeInExpo = CAMediaTimingFunction(controlPoints: 0.95, 0.05, 0.795, 0.035)
    public static let easeOutExpo = CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
    public static let easeInOutExpo = CAMediaTimingFunction(controlPoints: 1, 0, 0, 1)
    
    public static let easeInCirc = CAMediaTimingFunction(controlPoints: 0.6, 0.04, 0.98, 0.335)
    public static let easeOutCirc = CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
    public static let easeInOutCirc = CAMediaTimingFunction(controlPoints: 0.785, 0.135, 0.15, 0.86)
    
    public static let easeInBack = CAMediaTimingFunction(controlPoints: 0.6, -0.28, 0.735, 0.045)
    public static let easeOutBack = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
    public static let easeInOutBack = CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)
}

extension CAMediaTimingFunction: TimingFuncational {
    
    public func process(fractionComplete: Metric, duration: TimeInterval) -> Metric {
        let calculator = MediaTimingFunctionCalculator(timingFucntion: self, duration: duration)
        return calculator.progress(at: fractionComplete)
    }
}
