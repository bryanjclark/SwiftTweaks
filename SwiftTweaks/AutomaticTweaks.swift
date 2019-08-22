import UIKit

/*
 An AutomaticTweakList is any 'class' that conforms to this protocol.  
 It needs to be a class so that the Objective C runtime can have find it.
 Swift allows requiring the conformant object to be a class at compile time, 
 as shown below.
 
 The static property is just a way to access the singleton class.  
 These instances need to be singletons to allow to non-static tweak properties.

 Listed tweaks must be non-static properties of TweakType or TweakClusterType. 
 Simply declaring them as such in an AutomaticTweakList will cause them to appear
 in the list of all tweaks at runtime.

 Static tweak properties are not supported due to the lack of introspection of them in
 both the Swift and Objective C runtimes.
*/
public protocol AutomaticTweakList: class {
    static var tweakList: AutomaticTweakList { get }
}

/*
 Any AutomaticTweakList class that needs some sort of setup after the tweaks are 
 setup can conform to AutomaticTweakSetup.
 
 This setup() function will then be called to allow things like binding tweak values
 to be performed in the earliest possible code path.
*/
public protocol AutomaticTweakSetup: AutomaticTweakList {
    func setup()
}

/*
 AutomaticTweaks is a default TweakLibraryType that uses the objective C and swift 
 runtimes to discover and inspect implementations that conform to the 
 AutomaticTweakList and AutomaticTweakSetup protocols.  

 Since this is a runtime inspection, compile time restrictions like 'private' 
 and 'fileprivate' don't limit visiblity.  This means that tweaks can be spread 
 across files that use them and declared public only if they need to be accessed
 at compile time by some other part of the code.

 When using AutomaticTweaks, simply setup the window in the AppDelegate like this:

#if DEBUG
    self.window = AutomaticTweaks.window(from: self.window)
#endif

 and then pepper these around where you need them:

fileprivate let localTweaks = LocalTweaks()

fileprivate class LocalTweaks: AutomaticTweakList {
    public static var tweakList: AutomaticTweakList = localTweaks

    let numberOfThings = Tweak("General", "Stuff", "Number of Things", 0)
}

 While fileprivate is supported, it's not required, any swift access level works.

 The TweakGroup class can also be used in this context as so:

fileprivate let tweakGroup = TweakGroup("List Screen")
fileprivate let localTweaks = ListViewTweaks()

fileprivate class ListViewTweaks: AutomaticTweakList {
    public static var tweakList: AutomaticTweakList = localTweaks

    let pinLabelTextColor = tweakGroup.tweak("pin label text color", argb: 0xAA333333)
    let notSeen = tweakGroup.tweak("Not Seen", argb: 0xF4FFD800)
    let IGNOn = tweakGroup.tweak("IGN On", argb: 0xFF00CE00)
    let IGNOnText = tweakGroup.tweak("IGN On Text", .black)
}

*/
public class AutomaticTweaks: TweakLibraryType {

    /*
     Enable tweaks in the app delegate like this:

     #if DEBUG
        self.window = AutomaticTweaks.window(from: self.window)
     #endif

     By default the shake gesture is used to bring up the list of tweaks.  
     Any TweakWindow..GestureType can be used, including two finger double tap:

     #if DEBUG
        self.window = AutomaticTweaks.window(from: self.window,
		                                     gestureType: .twoFingerDoubleTap)
)
     #endif

     and a custom UITapGestureRecognizer:

     #if DEBUG
        let customGesture = UITapGestureRecognizer()
        customGesture.numberOfTapsRequired = 3
        customGesture.numberOfTouchesRequired = 3
        self.window = AutomaticTweaks.window(from: self.window,
		                                     gestureType: .gesture(customGesture))

        // this custom gesture recognizer needs be added to the view of your choice
        window.addGestureRecognizer(customGesture)
     #endif
    */  
    public static func window(from window: UIWindow?,
                              gestureType: TweakWindow.GestureType = .shake) -> UIWindow
    {
        let tweakWindow = TweakWindow(frame: UIScreen.main.bounds,
                                      gestureType: gestureType,
                                      tweakStore: self.defaultStore)
        if let rvc = window?.rootViewController {
            tweakWindow.rootViewController = rvc
        }
        self.setup()
        return tweakWindow
    }

    /*
     This default store of tweaks is assembled at runtime from a list of 
     all 'classes' that conform to the AutomaticTweakList protocol, from the ObjC runtime.

     For each found class, its default instance is accessed as a static member,
     and then the all non-static members of it that conform to TweakType are 
     added automatically to the list of tweaks displayed to the user.
    */
    public static let defaultStore: TweakStore = {
        var allTweaks: [TweakType] = []

        // grab class list that conforms to AutomaticTweakList protocol from the objc runtime 
        let tweakLists = listClasses { $0.compactMap { $0 as? AutomaticTweakList.Type } }

        for tweakList in tweakLists {
            let mirror = Mirror(reflecting: tweakList.tweakList)
            for child in mirror.children {
                // use swift Mirror to find all members conforming to TweakType,
                // and add them automatically to the list of tweaks shown to the user
                if let tweak = child.value as? TweakType {
                    allTweaks.append(tweak)
                } else if let cluster = child.value as? TweakClusterType {
                    // grab things like the SpringAnimationTweakTemplate here
                    for tweak in cluster.tweakCluster {
                        allTweaks.append(tweak)
                    }
                }
            }
        }

        #if DEBUG
            let tweaksEnabled: Bool = true
        #else
            // No tweaks in production
            let tweaksEnabled: Bool = false
        #endif

        let store = TweakStore(
            tweaks: allTweaks.map(AnyTweak.init),
            enabled: tweaksEnabled
        )

        return store
    }()

    public static func setup() {
        // grab class list that conforms to AutomaticTweakSetup protocol from the objc runtime 
        let tweakLists = listClasses { $0.compactMap { $0 as? AutomaticTweakSetup.Type } }

        for tweakList in tweakLists {
            if let setupClass = tweakList.tweakList as? AutomaticTweakSetup {
                setupClass.setup()
            }
        }
    }
}

// These extensions are some syntactic sugar for when using AutomaticTweaks
// They assume that the tweaks is registered automatically through AutomaticTweaks
public extension Tweak {

    /*
     Supports 

       let foo = tweak.foo.currentValue

     instead of 

       let foo = AutomaticTweaks.assign(tweak.foo)
     */
    var currentValue: T { return AutomaticTweaks.assign(self) }

    /*
     Supports

       tweak.foo.bind { value in
         // do something with every change to 'value'
       }

     instead of

       AutomaticTweaks.bind(tweak.foo) { value in
         // do something with every change to 'value'
       }
    */
    @discardableResult
    func bind(_ binding: @escaping (T) -> Void) -> TweakBindingIdentifier {
        return AutomaticTweaks.bind(self, binding: binding)
    }
}

public extension Tweak where T == StringOption {
    /*
     Without this extension property, 
     tweaks.foo.currentValue returns a StringOption instead of the 
     corresponding String value, acessable via the .value property as seen below
    */
    var currentValue: String { return AutomaticTweaks.assign(self).value }

    /*
     Without this extension func,

     tweaks.foo.bind { newValue in /*...*/ } 

     is called with newValue being StringOption, not the String value, 
     which is acessable via the .value property.

     However due to the type of newValue not being well defined, 
     the type must be specified as such to use this func:

     tweaks.foo.bind { (newValue: String) in /*...*/ } 
    */
    @discardableResult
    func bind(_ binding: @escaping (String) -> Void) -> TweakBindingIdentifier {
        return AutomaticTweaks.bind(self) { newValue in
            binding(newValue.value)
        }
    }
}

// black magic from the objc runtime
fileprivate func listClasses<T>(_ body: (UnsafeBufferPointer<AnyClass>) throws -> T) rethrows -> T {
  var cnt: UInt32 = 0
  let ptr = objc_copyClassList(&cnt)
  defer { free(UnsafeMutableRawPointer(ptr)) }
  let buf = UnsafeBufferPointer( start: ptr, count: Int(cnt) )
  return try body(buf)
}

