//
//  File.swift
//  
//
//  Created by Labtanza on 7/19/22.
//

import SwiftUI

struct ExamplesView: View {
    @State var slider1Value = 5.0
    @State var slider2Value = 50.0
    @State var slider3Value = 5.0
    @State var slider4Value = 5.0
    @State var slider5Value = 5.0
    
    //An example custom function. sin/asin only work for very tight domains.
    var customFunctionPair:FunctionPair {
        func exampleF(value:Double) -> Double {
            sin(value) + 1
        }
        func exampleI(value:Double) -> Double {
            asin(value - 1)
        }
        
        let validDomain = (Double.pi/6...Double.pi/3)
        
        return FunctionPair(function: exampleF, inverse: exampleI, domain: validDomain)!
    }
    
    var body: some View {
        VStack {
            Text("Slider 1 Value: \(slider1Value)")
            TaperSlider(value: $slider1Value, taperStyle: .logp1)
            Text("Slider 2 Value: \(slider2Value)")
            TaperSlider(value: $slider2Value, in: 0...100, taperStyle: .logp1)
            Text("Slider 3Value: \(slider3Value)")
            
            //fix below one issue / document issue for custom values.
            TaperSlider(
                value: $slider3Value,
                in: 1...10,
                taperStyle:  .customlogbase(base: 3),
                taperRange: 75...100.0)
            
            
            Text("Slider 4 Value: \(slider4Value)")
            TaperSlider(
                value: $slider4Value,
                in: 1...10,
                taperStyle: .customlogbase(base: 10)
            )
            
            Text("Slider 5 Value: \(slider5Value)")
            TaperSlider(
                value: $slider5Value,
                //must use inout range if not using a pre-clamped function.
                in: 1...10,
                //isClamped is false if the function isn't already returning
                //values in the desired output range.
                taperStyle: .dangereuse(pair: customFunctionPair, isClamped: false)
                //Not specifying the taperRange b/c it defaults to the functions domain for custom functions. In this case that works. When there is a large valid domain it gets a little weird. 
            )
        }
        
    }
}

struct ExampleTaperSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ExamplesView()
    }
}
