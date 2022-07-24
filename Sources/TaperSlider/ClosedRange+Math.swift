//
//  ClosedRange+Math.swift
//  
//
//  Created by Carlyn Maw on 7/19/22.
//

import Foundation

///Extension on Closed Range that makes some common math for working with ranges easier.
//TODO: For Range and ClosedRange?
//TODO: For Bounds in addition to Double? Worth the trouble? (Must be comparable, do division, etc)
extension ClosedRange where Bound == Double {
    
    //Assumes lowerbound is infact the smaller number.
    var span:Bound {
        upperBound - lowerBound
    }
    
    var signedspan:Bound {
        upperBound.magnitude - lowerBound.magnitude
    }
    
    var distanceFromZero:Bound {
        lowerBound.magnitude
    }
    
    var midpoint:Bound {
        signedspan/2 + lowerBound
    }
    
    func normalizedValue(_ value:Bound) -> Bound {
        (value - lowerBound)/span
    }
    
    func valueForNormal(_ percent:Double) -> Bound {
        span*percent + lowerBound
    }
//
//    func linearScaling(value:Bound, newRange:ClosedRange) -> Double {
//        guard self.contains(value) else {
//            fatalError("Value \(value) does not exist in \(self)")
//        }
//        let percentOfRange = self.normalizedValue(value)
//        return scale(percentage: percentOfRange, newRange: newRange)
//    }
//
//    func scale(percentage:Double, newRange:ClosedRange) -> Double {
//        guard (0...1).contains(percentage) else {
//            fatalError("value submitted does not represent a percentage.")
//        }
//        let positionInNewRange = (percentage * newRange.span) + newRange.lowerBound
//        return positionInNewRange
//    }
//
//    //What you'd need to map self to given range
//    func transformValues(toBecome range:ClosedRange) -> (multiplier:Double, shift:Double){
//        let multiplier = range.span / self.span
//        let constant = range.lowerBound - self.lowerBound
//
//        return (multiplier, constant)
//    }
//
//    func transformValues(from range:ClosedRange) -> (multiplier:Double, shift:Double){
//        let multiplier = self.span / range.span
//        let constant = self.lowerBound - range.lowerBound
//
//        return (multiplier, constant)
//    }

//    func transform(v:Double, m:Double, c:Double) -> Double {
//        return ((v-lowerBound)*m) + (c + lowerBound)
//    }
}
