//
//  File.swift
//  
//
//  Created by Labtanza on 7/19/22.
//

import Foundation
//Requires Taper, ClosedRange+Math

fileprivate extension Double {
    func fuzzyMatch(_ compareTo:Double) -> Bool {
        return (self - compareTo).magnitude < 0.00000001
    }
}

public struct FunctionPair {
    //Bijective
    let function: (Double) -> Double
    let inverse: (Double) -> Double
    let domain:ClosedRange<Double>
    var interestingRange:ClosedRange<Double>
    
    init?(function:@escaping (Double) -> Double, inverse: @escaping (Double) -> Double, domain:ClosedRange<Double>) {
        
        if FunctionPair.testRelationship(function: function, inverse: inverse, domain: domain) {
            self.function = function
            self.inverse = inverse
            self.domain = domain
            self.interestingRange = domain
        } else {
            return nil
        }
        
    }
    
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
    
    static func testRelationship(function:(Double) -> Double, inverse: (Double) -> Double, domain:ClosedRange<Double>) -> Bool {
        let result = true
        
        let minTest = runTest(domain.lowerBound, function: function, inverse: inverse)
        let maxTest = runTest(domain.upperBound, function: function, inverse: inverse)
        
        if !minTest || !maxTest {
            return false
        }
        
        for _ in 0...10 {
            let testCase = Double.random(in: domain)
            let testResult = runTest(testCase, function: function, inverse: inverse)
            if testResult == false {
                return false
            }
        }
        return result
    }
    
    static func runTest(_ testCase:Double, function:(Double) -> Double, inverse: (Double) -> Double) -> Bool {
        let result = true
        
        let fr = function(testCase)
        let ir = inverse(fr)
        print("for value \(testCase), function returns \(fr), inverse returns \(ir)")
        if !(inverse(function(testCase))).fuzzyMatch(testCase) {
            return false
        }
        return result
    }
    
    func printDescription() {
        let testCase = Double.random(in: domain)
        let functionResult = function(testCase)
        let inverseResult = inverse(functionResult)
        print("for value \(testCase), function returns \(functionResult), inverse returns \(inverseResult)")
        
    }
}
//MARK: Static Function Pair Builders
extension FunctionPair {
    
    static func customBaseInvLogPair(base:Double, multiplier:Double = 1.0) -> FunctionPair? {
        
        func myFunction(value:Double) -> Double { pow(base, value) * multiplier }
        func myInverse(value:Double) -> Double { customBaseLog(base: base, value: (value / multiplier)) }
        
        //Tested for positive non zero bases ranging from 0.3 to 10.2
        //fractional ± values for multiplier all okay.
        let myDomain:ClosedRange<Double> = -310...300
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )
    }
    
    //Tested for positive multipliers 0.0005 to 5000
    static func variableWidthLog1p(multiplier:Double) -> FunctionPair? {
        //function of form log(mx+1)
        //expm == eˣ-1  and log1p == log(1+x)
        
        func myFunction(value:Double) -> Double {  log1p(multiplier*value) }
        func myInverse(value:Double) -> Double { expm1(value)/multiplier }
        
        // lowerbound: fails below 0 if multiplier > 1, so just leaving it off for now.
        // upperbound: over ~1mil precision errors
        let myDomain:ClosedRange<Double> = 0...100000
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )
    }
    
    static func variableWidthExpm(multiplier:Double) -> FunctionPair? {
        //function of form log(mx+1)
        //expm == eˣ-1  and log1p == log(1+x)
        
        func myFunction(value:Double) -> Double { expm1(value)/multiplier  }
        func myInverse(value:Double) -> Double {  log1p(multiplier*value) }
        
        //lowerbounds: much below -19 looses too much precision to fuzzyMatch.
        //upperbounds: Higher than 700 Inverse returns inf
        let myDomain:ClosedRange<Double> = -19...700
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )
    }
    
    static func clampedLogPair(rangeOfInterest:ClosedRange<Double>, inoutRange:ClosedRange<Double>) -> FunctionPair? {
        //function of form log(mx+1)
        //expm == eˣ-1  and log1p == log(1+x)
        
        // lowerbound: fails below 0 if multiplier > 1, so just leaving it off for now.
        // upperbound: over ~1mil precision errors
        let validDomain:ClosedRange<Double> = 0...100000
        
        let newRange = rangeOfInterest.clamped(to: validDomain)
        guard newRange == rangeOfInterest else {
            fatalError("rangeOfInterest lies outside of valid domain for this function pair.")
        }
        let domainForPair = inoutRange
        
        func myVariableBaseFunction(value:Double) -> Double {
            let normalizedValue = inoutRange.normalizedValue(value)
            if !(0.0...1.1).contains(normalizedValue) {
                print("value submitted is out side the bounds of \(inoutRange.lowerBound) and \(inoutRange.upperBound)")
            }
            let valueToSubmit = rangeOfInterest.valueForNormal(normalizedValue)//(value - constant)/scale
            print("Submitted Value: \(valueToSubmit)")
            return log1p(valueToSubmit)
        }
        
        func myVariableBaseInverse(value:Double) -> Double {
            let returnValue = expm1(value)
            print("Returned Value: \(returnValue)")
            let shiftBack = rangeOfInterest.normalizedValue(returnValue)
            let expandIntoRange = inoutRange.valueForNormal(shiftBack)
            
            //        if !(0.0...1.1).contains(shiftBack) {
            //            print("Inverse is not returning a value between 0 and 1")
            //        }
            
            return expandIntoRange
        }
        return FunctionPair(function: myVariableBaseFunction, inverse: myVariableBaseInverse, domain: domainForPair)
    }
    
    func clampedPair(rangeOfInterest:ClosedRange<Double>, inoutRange:ClosedRange<Double>) -> FunctionPair? {
        FunctionPair.clampedPair(function: self.function, inverse: self.inverse, domain: self.domain, rangeOfInterest: rangeOfInterest, inoutRange: inoutRange)
    }
    
    static func clampedPair(for existingPair:FunctionPair, rangeOfInterest:ClosedRange<Double>, inoutRange:ClosedRange<Double>) -> FunctionPair? {
        clampedPair(function: existingPair.function, inverse: existingPair.inverse, domain: existingPair.domain, rangeOfInterest: rangeOfInterest, inoutRange: inoutRange)
    }
    
    static func clampedPair(function: @escaping (Double) -> Double, inverse: @escaping (Double) -> Double, domain:ClosedRange<Double>, rangeOfInterest:ClosedRange<Double>, inoutRange:ClosedRange<Double>) -> FunctionPair? {
        
        let newRange = rangeOfInterest.clamped(to: domain)
        guard newRange == rangeOfInterest else {
            fatalError("rangeOfInterest lies outside of valid domain for this function pair.")
        }
        
        func myVariableBaseFunction(value:Double) -> Double {
            let normalizedValue = inoutRange.normalizedValue(value)
            if !(0.0...1.1).contains(normalizedValue) {
                print("value submitted is out side the bounds of \(inoutRange.lowerBound) and \(inoutRange.upperBound)")
            }
            let valueToSubmit = rangeOfInterest.valueForNormal(normalizedValue)//(value - constant)/scale
            print("Submitted Value: \(valueToSubmit)")
            return function(valueToSubmit)
        }
        
        func myVariableBaseInverse(value:Double) -> Double {
            let returnValue = inverse(value)
            print("Returned Value: \(returnValue)")
            let shiftBack = rangeOfInterest.normalizedValue(returnValue)
            let expandIntoRange = inoutRange.valueForNormal(shiftBack)
            
            //        if !(0.0...1.1).contains(shiftBack) {
            //            print("Inverse is not returning a value between 0 and 1")
            //        }
            
            return expandIntoRange
        }
        return FunctionPair(function: myVariableBaseFunction, inverse: myVariableBaseInverse, domain: inoutRange)
    }
}


//MARK: Defined Pairs
extension FunctionPair {
    static let favoriteLogCurvePair:FunctionPair = {
        //function of form log(mx+1)
        return variableWidthLog1p(multiplier: 9)!
    }()
    
    static let favoriteInvLogPair:FunctionPair = {
        //function of form eˣ-1  (x == mx)
        return variableWidthExpm(multiplier: 9)!
    }()
    
    //Purely for test purposes. Will have no effect on a slider really.
    static let linearPair:FunctionPair  = {
        let slope = 2.0
        let intercept = 0.0
        
        func myFunction(_ value:Double) -> Double { (value * slope) + intercept }
        func myInverse(_ value:Double) -> Double {  (value - intercept) / 2 }
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: -1000.0...1000.0)!
    }()
    
    static var log2Pair:FunctionPair = {
        func myFunction(_ value:Double) -> Double { log2(value) }
        func myInverse(_ value:Double) -> Double {  pow(2, value) }
        
        //lower bounds 0.5 function returns -1, at 1 function returns 0.0
        //upper bounds not showing muc limit.
        let myDomain:ClosedRange<Double> = 1...1000000.0
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )!
    }()
    
    static let invlog2Pair:FunctionPair = {
        func myFunction(_ value:Double) -> Double { pow(2, value) }
        func myInverse(_ value:Double) -> Double { log2(value) }
        
        //lowerbounds: negative numbers work fine. See note on upperbound.
        //upperbounds: Magnitude much bigger than 1k fails.
        let myDomain:ClosedRange<Double> = -10000.0...10000.0
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )!
    }()
    
    static var log10Pair:FunctionPair = {
        func myFunction(_ value:Double) -> Double { log10(value) }
        func myInverse(_ value:Double) -> Double {  pow(10, value) }
        
        //lower bounds 0.5 function returns -1, at 1 function returns 0.0
        //upper bounds not showing muc limit.
        let myDomain:ClosedRange<Double> = 1...1000000.0
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )!
    }()
    
    static let invlog10Pair:FunctionPair = {
        func myFunction(_ value:Double) -> Double { pow(10, value) }
        func myInverse(_ value:Double) -> Double { log10(value) }
        
        //lowerbounds: negative numbers work fine. See note on upperbound.
        //upperbounds: Magnitude much bigger than 1k fails.
        let myDomain:ClosedRange<Double> = -10000.0...10000.0
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )!
    }()
    
    static private func customBaseLog(base:Double, value: Double) -> Double {
        return Darwin.log10(value)/Darwin.log10(base)
    }
    
    static func customBaseLogPair(base:Double, multiplier:Double = 1.0) -> FunctionPair? {
        
        func myFunction(value:Double) -> Double { (customBaseLog(base: base, value: value) * multiplier) }
        func myInverse(value:Double) -> Double {  pow(base, (value / multiplier)) }
        
        //Tested for positive non zero bases ranging from 0.3 to 10.2
        //fractional ± values for multiplier all okay.
        let myDomain:ClosedRange<Double> = 0.1...100000
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )
        
    }
    
}
