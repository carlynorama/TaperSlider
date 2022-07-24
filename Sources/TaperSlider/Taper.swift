//
//  Taper.swift
//  
//
//  Created by Labtanza on 7/19/22.
//

import Foundation
//Dependency: FunctionPair

///A data structure for how a taper will behave
public struct TaperProfile {
    let style:TaperStyle
    var rangeOfInterest:ClosedRange<Double>?
    var inoutRange:ClosedRange<Double>?
    
    ///The equation that will govern the taper's behavior.
    ///
    ///Built in taper behaviors
    ///| Style Name  | Description, where x is the submitted value                          |
    ///| ------------ | ------------------------------------- |
    ///| `logp1`       | log(1+x)  |
    ///| `expm1`        | eˣ-1        |
    ///| `customlogbase(base:Double)`       |  logᵦ(x)  Where ß is the submitted base             |
    ///| `dangereuse(pair:FunctionPair, isClamped:Bool)` | custom function pair, acknowledging whether it has been clamped to desired output range already.  |
    public enum TaperStyle {
        case logp1
        case expm1
        case customlogbase(base:Double)
        case custominvlogbase(base:Double)
        case dangereuse(pair:FunctionPair, isClamped:Bool)
    }
}

//MARK: Default Behaviors

extension TaperProfile.TaperStyle {
    var defaultRangeOfInterest:ClosedRange<Double> {
        switch self {
            
        case .logp1:
            return 0.0...9.0
        case .expm1:
            return 0.0...1.5
        case .customlogbase(_):
            return 0.7...2 //TODO: Better values
        case .custominvlogbase(_):
            return 0.7...2 //TODO: Better values
        case .dangereuse(pair: let pair, isClamped: let isClamped):
            if isClamped {
                return pair.domain
            } else {
                // Needs to be the same as in defaultInoutRange below.
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
