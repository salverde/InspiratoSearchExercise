Unbox and Alamofire in Swift 3
===
#### Inspirato Coding Exercise (iOS Developer position)
**_is is where this spawned from_**

**Project tools, dependencies, and setup**

* Xcode 8
* Swift 3
* ————
* Alamofire (HTTP networking lib)
* Unbox (Swift JSON decoder)
* UnboxedAlamofire (Custom Response Serializer for Unbox)
* AlamofireImage (Image response serializer for Alamofire)
* SnapKit (Swift Autolayout DSL)
* —————
* Git `git clone git@github.com:salomoko/InspiratoSearchExercise.git`
* Cocoapods (1.1.1) - `pod install`

The reasoning I made this exercise a public repo is not to help other candidates that may not be qualified but rather to provide an  example of using [Unbox](https://github.com/JohnSundell/Unbox) with [Alamofire](https://github.com/serejahh/UnboxedAlamofire) in Swift 3!
IMO I think this is a very simple/clean solution to a very common task iOS developers face regularly. The serialization is handled very nicely as property types are automatically detected and decoded. All missing or mismatched values are gracefully handled through a single exception type, making error handling super simple!
Your models aren't saturated with optional properties, that you later have to unwrap, guard or add more LOC at some point.
And best of all its a light weight solution that you can use with your protocol oriented swift apps!

---

_This example is simply meant to critique and/or get ideas off of. I ended up NOT receiving an offer from them, stating something along the lines of your code was very elegant and clean but it didn't touch on the areas they were looking for. Whatever that means, I'm assuming because I failed to implement AutoLayout on a couple screens, simply spaced it!_



