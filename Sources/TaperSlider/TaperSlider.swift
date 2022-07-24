//
//  TaperSlider.swift
//
//
//  Created by Carlyn Maw on 7/15/22.
//  License MIT
//
// Thanks to:
// https://gist.github.com/prachigauriar/c508799bad359c3aa271ccc0865de231

import SwiftUI

///A wrapper around Slider() that takes a TaperProfile to create a variable stride.
///
///
///- Parameter value:A binding to the value to be updated by the slider.
///- Parameter outputRange: Optional. The range of values the slider will take in and output.  Default is 0...1
///- Parameter taperStyle: The curve of the rate of change for the slider, a ``TaperProfile.TaperStyle``
///- Parameter taperInputRange: Optional. The part of the `taperStyle` curve that is the most interesting. Built in TaperStyles have their own defaults.
///- Parameter onEditingChanged: Optional. Passthrough to the underlying Slider()
public struct TaperSlider: View {
    @Binding var value:Double
    var pair:FunctionPair?

    var onEditingChanged: (Bool) -> Void
    
    public init(value:Binding<Double>, outputRange range: ClosedRange<Double>? = nil, taperStyle:TaperProfile.TaperStyle, taperInputRange:ClosedRange<Double>? = nil, onEditingChanged: @escaping (Bool) -> Void = { _ in }) {
       
        let profile = TaperProfile(style: taperStyle, rangeOfInterest: taperInputRange, inoutRange: range)
        let attemptedPair = FunctionPair(profile: profile)
        
        pair = attemptedPair

        self._value = value
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        if let pair = self.pair {
            Slider.withCustomTaper(value: $value, withPair: pair)
        } else {
            Text("Slider taper function unable to validate.")
        }
    }
}


//struct CustomTaperSider_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomTaperSlider(taperStyle: .linear, value: .constant(4.0), in: 1...10)
//    }
//}


fileprivate extension Binding where Value == Double {
    //Creates a binding that will smoothly update the slider based on the custom function pair.
    func customTaper(_ functionPair:FunctionPair) -> Binding<Double> {
        Binding(
            get: {
                let v = functionPair.function(self.wrappedValue)
                //print("GETTER wrapped:\(self.wrappedValue), output:\(v)")
                return v
            },
            set: { (newValue) in
                let calculatedValue = functionPair.inverse(newValue)
                //print("SETTER input:\(newValue), calculated:\(calculatedValue)")
                self.wrappedValue = calculatedValue
            }
        )
    }
}

//TODO: Passthrough Label, ValueLabel
fileprivate extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    
    //Returns a slider with the alternate binding.
    static func withCustomTaper(
        value: Binding<Double>,
        withPair functionPair:FunctionPair,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) -> Slider {
        return self.init(
            value: value.customTaper(functionPair),
            in: functionPair.function(functionPair.domain.lowerBound) ... functionPair.function(functionPair.domain.upperBound),
            onEditingChanged: onEditingChanged
        )
    }
}







