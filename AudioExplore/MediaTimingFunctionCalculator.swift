//
//  MediaTimingFunctionCalculator.swift
//  AnimationEngine
//
//  Created by Evan Xie on 2019/11/20.
//  Copyright © 2019 UBTech. All rights reserved.
//

import Foundation
import QuartzCore

public final class MediaTimingFunctionCalculator {
    
    fileprivate let bezier: UnitBezier
    fileprivate let epsilon: Metric
    fileprivate let duration: Metric
    
    public init(timingFucntion: CAMediaTimingFunction, duration: TimeInterval = 1.0) {
        
        self.duration = Metric(duration)
        self.epsilon = 1.0 / (200.0 * self.duration)
        
        var p0: Float = 0, p1: Float = 0, p2: Float = 0, p3: Float = 0
        timingFucntion.getControlPoint(at: 0, values: &p0)
        timingFucntion.getControlPoint(at: 1, values: &p1)
        timingFucntion.getControlPoint(at: 2, values: &p2)
        timingFucntion.getControlPoint(at: 3, values: &p3)

        bezier = UnitBezier(controlPoint1: (x: Metric(p0), y: Metric(p1)), controlPoint2: (x: Metric(p2), y: Metric(p3)))
    }
    
    /// Returns the progress along the timing function for the given time (`fractionComplete`)
    /// with `0.0` equal to the start of the curve, and `1.0` equal to the end of the curve
    public func progress(at fractionComplete: Metric) -> Metric {
        return bezier.value(for: fractionComplete, epsilon: epsilon)
    }
  
}


 /*
 * Copyright (C) 2008 Apple Inc. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  https://opensource.apple.com/source/WebCore/WebCore-955.66/platform/graphics/UnitBezier.h
 */

fileprivate struct UnitBezier {
    
    typealias Point = (x: Metric, y: Metric)
    
    // MARK: - Properties
    
    private let ax: Metric
    private let bx: Metric
    private let cx: Metric
    
    private let ay: Metric
    private let by: Metric
    private let cy: Metric
    
    // MARK: - Initialiser
    
    init(controlPoint1: Point, controlPoint2: Point) {
        
        // Calculate the polynomial coefficients, implicit first
        // and last control points are (0,0) and (1,1).
        
        cx = 3.0 * controlPoint1.x
        bx = 3.0 * (controlPoint2.x - controlPoint1.x) - cx
        ax = 1.0 - cx - bx
        
        cy = 3.0 * controlPoint1.y
        by = 3.0 * (controlPoint2.y - controlPoint1.y) - cy
        ay = 1.0 - cy - by
    }
    
    // MARK: - Methods
    func value(for x: Metric, epsilon: Metric) -> Metric {
        return sampleCurveY(solveCurveX(x, epsilon: epsilon))
    }
    
    // MARK: - Private Methods
    private func sampleCurveX(_ t: Metric) -> Metric {
        // `ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
        return ((ax * t + bx) * t + cx) * t
    }
    
    private func sampleCurveY(_ t: Metric) -> Metric {
        return ((ay * t + by) * t + cy) * t
    }
    
    private func sampleCurveDerivativeX(_ t: Metric) -> Metric {
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }
    
    // Given an x value, find a parametric value it came from.
    private func solveCurveX(_ x: Metric, epsilon: Metric) -> Metric {
        var t0, t1, t2, x2, d2: Metric
        
        // First try a few iterations of Newton's method -- normally very fast.
        
        t2 = x
        for _ in (0..<8) {
            x2 = sampleCurveX(t2) - x
            guard abs(x2) >= epsilon else { return t2 }
            d2 = sampleCurveDerivativeX(t2)
            guard abs(d2) >= 1e-6 else { break }
            t2 = t2 - x2 / d2
        }
        
        // Fall back to the bisection method for reliability.
        
        t0 = 0.0
        t1 = 1.0
        t2 = x
        
        guard t2 >= t0 else { return t0 }
        guard t2 <= t1 else { return t1 }
        
        while t0 < t1 {
            
            x2 = sampleCurveX(t2)
            
            guard abs(x2 - x) >= epsilon else { return t2 }
            
            if x > x2 {
                t0 = t2
            } else {
                t1 = t2
            }
            
            t2 = (t1 - t0) * 0.5 + t0
        }
        
        // Failure
        
        return t2
    }
}

