//
//  Taper.swift
//  
//
//  Created by Carlyn Maw on 7/19/22.
//

import Foundation
//Dependency: FunctionPair

///A data structure for how a taper will behave
public struct TaperProfile {
    /// The curve equation, with many prebuilt options as a ``TaperStyle``
    public let style:TaperStyle
    /// The part of the curve to use for mapping
    public private(set) var rangeOfInterest:ClosedRange<Double>?
    /// The range of values that curve's area of interest should be mapped to.
    public private(set) var inoutRange:ClosedRange<Double>?
    
    ///The equation that will govern the taper's behavior.
    ///
    ///Built in taper behaviors
    ///| Style Name  | Description, where x is the submitted value    |
    ///| ------------ | ------------------------------------- |
    ///| `logp1`       | log(1+x)  |
    ///| `expm1`        | eˣ-1        |
    ///| `customlogbase(base:Double)`       |  logᵦ(x)  Where ß is the submitted base    |
    ///| `custominvlogbase(base:Double)`       |  ßˣ  Where ß is the submitted base     |
    ///| `dangereuse(pair:FunctionPair, isClamped:Bool)` | custom function pair, acknowledging whether it has been clamped to desired output range already.  |
    public enum TaperStyle {
        ///log(1+x)
        case logp1
        
        /// eˣ-1
        case expm1
        
        ///logᵦ(x)  Where ß is the submitted base
        case customlogbase(base:Double)
        
        ///ßˣ  Where ß is the submitted base
        case custominvlogbase(base:Double)
        
        ///Ill-advised option to pass a raw function pair.
        ///
        /// If the parameter is not clamped the inoutRange and the rangeOfInterest had best be specified when using this option in a profile.
        ///- Parameter pair: Function pair that may or may not be clamped
        ///- Parameter isClamped: Boolean which serves as a reminder that the better behavior is to be clamped.
        case dangereuse(pair:FunctionPair, isClamped:Bool)
    }
}

//MARK: Default Behaviors

extension TaperProfile.TaperStyle {
    //These values are a matter of taste.
    var defaultRangeOfInterest:ClosedRange<Double> {
        switch self {
            
        case .logp1:
            return 0.0...9.0
        case .expm1:
            return 0.0...1.5
        case .customlogbase(_):
            return 0.2...4
        case .custominvlogbase(_):
            return -2.0...0.9
        case .dangereuse(pair: let pair, isClamped: let isClamped):
            if isClamped {
                return pair.domain
            } else {
                // Picked 1 to 2 because seems lower likelihood to have an asymptote.
                return 1.0...2.0
            }
        }
    }
    
    var defaultInoutRange:ClosedRange<Double> {
        
        switch self {
        case .dangereuse(pair: let pair, isClamped: let isClamped):
            if isClamped {
                return pair.domain
            } else {
                return 0.0...1.0
            }
        default:
            return 0.0...1.0
        }
        
    }
}
