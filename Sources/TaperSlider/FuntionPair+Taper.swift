//
//  FuntionPair+Taper.swift
//  
//
//  Created by Carlyn Maw on 7/24/22.
//

import Foundation


extension FunctionPair {
    
    ///Creates a "Clamped Pair" from a TaperProfile
    ///
    ///A slider binding takes only a ClampedPair. The input range == the output range, but the segment of the FunctionPair's curve being used is independent of that inoutRange. This function takes in a taper profile to create the pair.
    ///- Parameter profile: a ``TaperProfile``
    init?(profile: TaperProfile) {
        let iorange = profile.inoutRange ?? profile.style.defaultInoutRange
        let functionrange = profile.rangeOfInterest ?? profile.style.defaultRangeOfInterest
        
        var attemptedpair:FunctionPair? = nil
        
        switch profile.style {
            
        case .logp1:
            attemptedpair = FunctionPair.clampedPair(
                for: .variableWidthLog1p(multiplier: 1)!,
                rangeOfInterest: functionrange,
                inoutRange: iorange)
        case .expm1:
            attemptedpair = FunctionPair.clampedPair(
                for: .variableWidthExpm(multiplier: 1)!,
                rangeOfInterest: functionrange,
                inoutRange: iorange)
        case .customlogbase(base: let base):
            attemptedpair = FunctionPair.clampedPair(
                for: .customBaseLogPair(base: base)!,
                rangeOfInterest: functionrange,
                inoutRange: iorange)
        case .custominvlogbase(base: let base):
            attemptedpair = FunctionPair.clampedPair(
                for: .customBaseInvLogPair(base: base)!,
                rangeOfInterest: functionrange,
                inoutRange: iorange)
        case .dangereuse(pair: let pair, isClamped: let isClamped):
            if isClamped {
                attemptedpair = pair
            } else {
                attemptedpair = FunctionPair.clampedPair(
                    for: pair,
                    rangeOfInterest: profile.rangeOfInterest ?? pair.domain,
                    inoutRange: iorange)
            }
        }
        
        
        if attemptedpair != nil {
            self = attemptedpair!
        } else {
            return nil
        }
    }
    
}
