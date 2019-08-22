import UIKit
import SwiftTweaks

public let publicTweaks = PublicTweaks()

/*
 Any code in this app can access these tweaks like so:

   if publicTweaks.logDebugOnStartup.currentValue {
     print("We're starting up")
   }

   let identifier = publicTweaks.logDebugOnStartup.bind { newValue in
     if newValue {
       print("We're NO LONGER going to log debug on startup")
     } else {
       print("We're NOW going to log debug on startup")
     }
   }
*/
public class PublicTweaks: AutomaticTweakList {
    public static var tweakList: AutomaticTweakList = publicTweaks

	public let logDebugOnStartup = Tweak("Feature Flags", "Public", "Log Debug on Startup", true)
}
