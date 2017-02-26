//
//  Preferences.swift
//
//  Copyright © 2017 iDevGames. All rights reserved.
//

import Cocoa



struct Prefs {
	
	static func registerDefaults(_ inDefaults: [String : AnyObject] = [:]) {
		var defaults: [String : AnyObject] = inDefaults
		
		if let path = Bundle.main.path(forResource: "Defaults", ofType: "plist") {
			if let file = NSDictionary(contentsOfFile: path) as? [String : AnyObject] {
				for (k, v) in file {
					defaults[k] = v
				}
			}
		}
		
		UserDefaults.standard.register(defaults: defaults)
	}
}	






// MARK: - 

protocol Defaultable {
	static func read(defaults: UserDefaults, key: String) -> Self?
	func write(defaults: UserDefaults, key: String)
}


protocol Preference {
	var key: String { get }
}



struct OptionalPref<T: Defaultable>: Preference {
	let key: String
	
	init(_ key: String) {
		self.key = key
	}
	
	var value: T? {
		get {
			return T.read(defaults: UserDefaults.standard, key: key)
		}
		nonmutating set {
			if let nv = newValue {
				nv.write(defaults: UserDefaults.standard, key: key)
			} else {
				UserDefaults.standard.removeObject(forKey: key)
			}
		}
	}
}


struct Pref<T: Defaultable>: Preference {
	let key: String
	
	init(_ key: String) {
		self.key = key
	}
	
	var value: T {
		get {
			return T.read(defaults: UserDefaults.standard, key: key)!
		}
		nonmutating set {
			newValue.write(defaults: UserDefaults.standard, key: key)
		}
	}
}





// MARK: - Defaultable Types

extension String: Defaultable {
	static func read(defaults: UserDefaults, key: String) -> String? {
		return defaults.string(forKey: key)
	}
	
	func write(defaults: UserDefaults, key: String) {
		defaults.set(self, forKey: key)
	}
}



extension Int: Defaultable {
	static func read(defaults: UserDefaults, key: String) -> Int? {
		return defaults.integer(forKey: key)
	}
	
	func write(defaults: UserDefaults, key: String) {
		defaults.set(self, forKey: key)
	}
}



extension Bool: Defaultable {
	static func read(defaults: UserDefaults, key: String) -> Bool? {
		return defaults.bool(forKey: key)
	}
	
	func write(defaults: UserDefaults, key: String) {
		defaults.set(self, forKey: key)
	}
}



extension Float: Defaultable {
	static func read(defaults: UserDefaults, key: String) -> Float? {
		return defaults.float(forKey: key)
	}
	
	func write(defaults: UserDefaults, key: String) {
		defaults.set(self, forKey: key)
	}
}



extension Double: Defaultable {
	static func read(defaults: UserDefaults, key: String) -> Double? {
		return defaults.double(forKey: key)
	}
	
	func write(defaults: UserDefaults, key: String) {
		defaults.set(self, forKey: key)
	}
}


