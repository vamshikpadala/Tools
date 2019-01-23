//
//  AppFontManager.swift
//
//  Created by Vamshi krishna Padala on 22/01/19.
//  Copyright © 2019 Vamshi krishna Padala. All rights reserved.
//

import Foundation

class AppFontManager {
	
	//
	// fonts resources must match this convention: Family-Style, e.g. Lato-Bold (case-insensitive)
	//
	enum FontStyle {
		case regular, semibold, bold, light, medium, black, italic
	}
	
	//
	// font family name constant
	//
	fileprivate static let fontFamiliy = "Lato"
	
	//
	// private in-memory cache
	//
	fileprivate static var cache = [String: UIFont]()
	
	//
	// example call: AppFontManager.appFont(.regular, size: 17.0)
	//
	static func appFont(_ style: FontStyle, size: CGFloat) -> UIFont {
		
		let key = makeKey(style, size: size)
		
		if let font = cache[key] {
			
			//print("using cached font: \(font)")
			
			return font
		}
		
		if let font = UIFont(name: "\(fontFamiliy)-\(style)", size: size) {
			
			//print("creating and caching font \(key)")
			
			cache[key] = font
			
			return font
		}
		
		// not available, return system font
		
		Logger.shared.log("WARN: font not available: \(fontFamiliy)-\(style), using system font", level: .warning)
		
		return UIFont.systemFont(ofSize: size)
	}
	
	//
	// create a key for caching the font nased on it's style and size
	//
	fileprivate static func makeKey(_ style: FontStyle, size: CGFloat) -> String {
		
		return "\(style)-\(size)"
	}
}
