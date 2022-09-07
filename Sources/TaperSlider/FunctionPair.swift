//
//  FunctionPair.swift
//  
//
//  Created by Carlyn Maw on 7/19/22.
//

import Foundation
//Requires Taper, ClosedRange+Math

fileprivate extension Double {
    func fuzzyMatch(_ compareTo:Double) -> Bool {
        return (self - compareTo).magnitude < 0.00000001
    }
}

///A struct that contains a function, it's inverse, and the range of numbers where the relationship is valid.
///
///This struct is public to allow a developer to create custom FunctionPairs for their application. The initializer fails if the function and it's inverse aren't valid for the domain given.
///The test  runs `inverse(function(value)) == value` for `domain.lowerbound`, `domain.upperbound` and 10 random values inside the domain.
///The function must be bijective for domain, i.e. for the sets of submitted values and result values: "each element of one set is paired with exactly one element of the other set, and each element of the other set is paired with exactly one element of the first set"
public struct FunctionPair {
    let function: (Double) -> Double
    let inverse: (Double) -> Double
    let domain:ClosedRange<Double>
    
    ///General FunctionPair creation.
    ///
    ///- Parameter function: function determining the rate of change as the slider increases.
    ///- Parameter inverse: function that is the inverse of the first parameter
    ///- Parameter domain: The range of numbers for which that relationship holds true.
    public init?(function:@escaping (Double) -> Double, inverse: @escaping (Double) -> Double, domain:ClosedRange<Double>) {
        
        if FunctionPair.testRelationship(function: function, inverse: inverse, domain: domain) {
            self.function = function
            self.inverse = inverse
            self.domain = domain
        } else {
            return nil
        }
        
    }
    
    ///Returns a function pair  mapped to an input/output range based on what part of the function pair's curve is most interesting.
    ///
    /// Also referred to as a "clamped pair" type.
    ///- Parameter function: function determining the rate of change as the slider increases.
    ///- Parameter inverse: function that is the inverse of the first parameter
    ///- Parameter domain: The range of numbers for which that relationship holds true.
    ///- Parameter rangeOfInterest: what part of the log function's curve should be the basis of the map
    ///- Parameter inoutRange: range of values that the function will take in and return
    public init?(function: @escaping (Double) -> Double, inverse: @escaping (Double) -> Double, domain:ClosedRange<Double>, rangeOfInterest:ClosedRange<Double>, inoutRange:ClosedRange<Double>) {
        if let attemptedPair:FunctionPair = Self.clampedPair(function: function, inverse: inverse, domain: domain, rangeOfInterest: rangeOfInterest, inoutRange: inoutRange) {
            self = attemptedPair
        } else {
            return nil
        }
    }
    
    
    private static func testRelationship(function:(Double) -> Double, inverse: (Double) -> Double, domain:ClosedRange<Double>) -> Bool {
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
    
    private static func runTest(_ testCase:Double, function:(Double) -> Double, inverse: (Double) -> Double) -> Bool {
        let result = true
        
//        let fr = function(testCase)
//        let ir = inverse(fr)
        //print("for value \(testCase), function returns \(fr), inverse returns \(ir)")
        if !(inverse(function(testCase))).fuzzyMatch(testCase) {
            return false
        }
        return result
    }
    
    ///String with the form: `"for value \(testCase), function returns \(functionResult), inverse returns \(inverseResult)"` where testCase is a random value in the range.
    var description:String {
        let testCase = Double.random(in: domain)
        let functionResult = function(testCase)
        let inverseResult = inverse(functionResult)
        return String("for value \(testCase), function returns \(functionResult), inverse returns \(inverseResult)")
        
    }
}
//MARK: Static Function Pair Builders
extension FunctionPair {
    
    ///logᵦ(x)
    static func customBaseLogPair(base:Double) -> FunctionPair? {
        
        func myFunction(value:Double) -> Double { (customBaseLog(base: base, value: value)) }
        func myInverse(value:Double) -> Double {  pow(base, (value)) }
        
        //Tested for positive non zero bases ranging from 0.3 to 10.2
        //fractional ± values for multiplier all okay.
        let myDomain:ClosedRange<Double> = 0.1...100000
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )
        
    }
    
    ///ßˣ  Where ß is the submitted base
    static func customBaseInvLogPair(base:Double) -> FunctionPair? {
        
        func myFunction(value:Double) -> Double { pow(base, value) }
        func myInverse(value:Double) -> Double { customBaseLog(base: base, value: (value)) }
        
        //Tested for positive non zero bases ranging from 0.3 to 10.2
        let myDomain:ClosedRange<Double> = -310...300
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )
    }
    
    ///Function pair with form log(mx+1)
    ///
    ///- Parameter multiplier: Double for m
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
    
    ///Function pair with form form eˣ-1, (x == mx)
    ///
    ///- Parameter multiplier: Double for m
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
}

//MARK: Clamped Pair Builders
extension FunctionPair {

    ///Returns a function pair  mapped to an input/output range based on what part of the function pair's curve is most interesting.
    ///
    ///- Parameter function: function determining the rate of change as the slider increases.
    ///- Parameter inverse: function that is the inverse of the first parameter
    ///- Parameter domain: The range of numbers for which that relationship holds true.
    ///- Parameter rangeOfInterest: what part of the log function's curve should be the basis of the map
    ///- Parameter inoutRange: range of values that the function will take in and return
    //TODO: Throw instead of crash.
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
            //print("Submitted Value: \(valueToSubmit)")
            return function(valueToSubmit)
        }
        
        func myVariableBaseInverse(value:Double) -> Double {
            let returnValue = inverse(value)
            //print("Returned Value: \(returnValue)")
            let shiftBack = rangeOfInterest.normalizedValue(returnValue)
            let expandIntoRange = inoutRange.valueForNormal(shiftBack)
            
            //        if !(0.0...1.1).contains(shiftBack) {
            //            print("Inverse is not returning a value between 0 and 1")
            //        }
            
            return expandIntoRange
        }
        return FunctionPair(function: myVariableBaseFunction, inverse: myVariableBaseInverse, domain: inoutRange)
    }
    
    ///Returns a function pair built around log(1+x) mapped to an input/output range based on what part of the function pair's curve is most interesting.
    ///
    ///- Parameter rangeOfInterest: what part of the log function's curve should be the basis of the map
    ///- Parameter inoutRange: range of values that the function will take in and return
    //TODO: Throw errors.
    //Note: This was the test case before the more generic clampedPair was built below
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
            //print("Returned Value: \(returnValue)")
            let shiftBack = rangeOfInterest.normalizedValue(returnValue)
            let expandIntoRange = inoutRange.valueForNormal(shiftBack)
            
            //        if !(0.0...1.1).contains(shiftBack) {
            //            print("Inverse is not returning a value between 0 and 1")
            //        }
            
            return expandIntoRange
        }
        return FunctionPair(function: myVariableBaseFunction, inverse: myVariableBaseInverse, domain: domainForPair)
    }
    
    ///Returns a function pair built around this function pair mapped to an input/output range based on what part of this function pair's curve is most interesting.
    public func clampedPair(rangeOfInterest:ClosedRange<Double>, inoutRange:ClosedRange<Double>) -> FunctionPair? {
        FunctionPair.clampedPair(function: self.function, inverse: self.inverse, domain: self.domain, rangeOfInterest: rangeOfInterest, inoutRange: inoutRange)
    }
    
    ///Returns a function pair built around submitted function pair mapped to an input/output range based on what part of the function pair's curve is most interesting. A "Clamped Pair"
    static func clampedPair(for existingPair:FunctionPair, rangeOfInterest:ClosedRange<Double>, inoutRange:ClosedRange<Double>) -> FunctionPair? {
        clampedPair(function: existingPair.function, inverse: existingPair.inverse, domain: existingPair.domain, rangeOfInterest: rangeOfInterest, inoutRange: inoutRange)
    }
    

}


//MARK: Defined Pairs
public extension FunctionPair {
    ///Function pair with form log(9x+1) Nice curve present between 0 and 1
    static let favoriteLogCurvePair:FunctionPair = {
        //function of form log(mx+1)
        return variableWidthLog1p(multiplier: 9)!
    }()
    
    ///Function pair with form form eˣ-1, (x == 9x) Nice curve present between 0 and 1
    static let favoriteInvLogPair:FunctionPair = {
        return variableWidthExpm(multiplier: 9)!
    }()
    
    //Purely for test/example purposes. Will have no effect on a slider really.
    private static let linearPair:FunctionPair  = {
        let slope = 2.0
        let intercept = 0.0
        
        func myFunction(_ value:Double) -> Double { (value * slope) + intercept }
        func myInverse(_ value:Double) -> Double {  (value - intercept) / 2 }
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: -1000.0...1000.0)!
    }()
    
    ///log₂ function pair
    static var log2Pair:FunctionPair = {
        func myFunction(_ value:Double) -> Double { log2(value) }
        func myInverse(_ value:Double) -> Double {  pow(2, value) }
        
        //lower bounds 0.5 function returns -1, at 1 function returns 0.0
        //upper bounds not showing much limit.
        let myDomain:ClosedRange<Double> = 1...1000000.0
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )!
    }()
    
    ///2ˣ function pair
    static let invlog2Pair:FunctionPair = {
        func myFunction(_ value:Double) -> Double { pow(2, value) }
        func myInverse(_ value:Double) -> Double { log2(value) }
        
        //lowerbounds: negative numbers work fine. See note on upperbound.
        //upperbounds: Magnitude much bigger than 1k fails.
        let myDomain:ClosedRange<Double> = -10000.0...10000.0
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )!
    }()
    
    ///log₁₀ function pair
    static var log10Pair:FunctionPair = {
        func myFunction(_ value:Double) -> Double { log10(value) }
        func myInverse(_ value:Double) -> Double {  pow(10, value) }
        
        //lower bounds 0.5 function returns -1, at 1 function returns 0.0
        //upper bounds not showing muc limit.
        let myDomain:ClosedRange<Double> = 1...1000000.0
        
        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )!
    }()
    
    ///10ˣ function pair
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
    
//    static func customBaseLogPair(base:Double, multiplier:Double = 1.0) -> FunctionPair? {
//
//        func myFunction(value:Double) -> Double { (customBaseLog(base: base, value: value) * multiplier) }
//        func myInverse(value:Double) -> Double {  pow(base, (value / multiplier)) }
//
//        //Tested for positive non zero bases ranging from 0.3 to 10.2
//        //fractional ± values for multiplier all okay.
//        let myDomain:ClosedRange<Double> = 0.1...100000
//
//        return FunctionPair(function: myFunction, inverse: myInverse, domain: myDomain )
//
//    }
    
}
