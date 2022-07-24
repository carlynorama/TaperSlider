# TaperSlider

This package provides a slider that can provide non-linear tapers built in to the slider. It has some built in functions, but the developer can provide thier own function and it's inverse pair.

[![Swift Version][swift-image]][swift-url]

## Installation

Requires:
    Platform targets iOS 15 or later, MacOS 11 or later
    SwiftUI

It is still under development, but mostly bug fixes at this time. 

## Usage example

See the ExamplesView in the package but generally once can call it simply:

```
TaperSlider(value: $slider1Value, taperStyle: .logp1)
```

with more specificty:

```
TaperSlider(
    value: $slider3Value,
    outputRange: 1...10,
    taperStyle:  .custominvlogbase(base: 3),
    taperInputRange: 0.5...1.2
)
```

or even with a cutom function pair:
```
TaperSlider(
    value: $slider5Value,
    outputRange: 1...10,
    taperStyle: .dangereuse(pair: customFunctionPair, isClamped: false)
    taperInputRange: safeRange
)
```



## Release History

* 0.0.0
    * Current State. Wouldn't exactly call it "released"


## References [references]


* [Gist with a log10 example](https://gist.github.com/prachigauriar/c508799bad359c3aa271ccc0865de231) talk
* Alternate approach with an ["adaper binding"](https://stackoverflow.com/questions/59311887/swiftui-can-i-use-binding-get-set-custom-binding-with-binding-property-wrapper) from "Meet WeatherKit"
* [More on Custom Bindings](https://swiftwithmajid.com/2020/04/08/binding-in-swiftui/) including "Reducer" example.


## Contact and Contributing

Feature not yet available.

[swift-image]:https://img.shields.io/badge/swift-5.7-orange.svg
[swift-url]: https://swift.org/
