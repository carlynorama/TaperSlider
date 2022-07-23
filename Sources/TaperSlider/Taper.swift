//
//  File.swift
//  
//
//  Created by Labtanza on 7/19/22.
//

import Foundation
//Dependancy: FunctionPair

public struct TaperProfile {
    let style:TaperStyle
    var rangeOfInterest:ClosedRange<Double>?
    var inoutRange:ClosedRange<Double>?
    
    public enum TaperStyle {
        case logp1
        case expm1
        case customlogbase(base:Double)
        case custominvlogbase(base:Double)
        case dangereuse(pair:FunctionPair, isClamped:Bool)
    }
}

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
                return 1.0...9.0 // this is a dumb range.
            }
        }
    }
    
    var defaultInoutRange:ClosedRange<Double> {
        
        switch self {
        case .dangereuse(pair: let pair, isClamped: let isClamped):
            if isClamped {
                return pair.domain
            } else {
                return 1.0...9.0 // this is a dumb range. needs to be the same as in dRoI above.
            }
        default:
            return 0.0...1.0
        }
        
    }
}
//
//enum TaperStyle {
//    case linear
//    case log
//    case invlog
//    case variaton(TaperProfile)
//    case custom(FunctionPair)
//    case currentTest
//}
//
//extension TaperStyle {
//    var functionPair:FunctionPair {
//        switch self {
//
//        case .linear:
//            return FunctionPair.linearPair
//        case .log:
//            return FunctionPair.favoriteLogCurvePair
//        case .invlog:
//            return FunctionPair.favoriteInvLogPair
//        case .variaton(let profile):
//            //TODO: Throw error instead of crash.
//            return FunctionPair(profile: profile)!
//        case .custom(let pair):
//            return pair
//        case .currentTest:
//            //return FunctionPair.variableWidthLog(multiplier: 9.0)!
//            //multiplier doesn't seem to make much of a diff on inverse.
//            return FunctionPair.variableWidthLog1p(multiplier: 9.0)!
//            //return FunctionPair.variableWidthLog(rangeOfInterest: 1...5)!
//        }
//    }
//}
