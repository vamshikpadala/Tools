//
//  Extensions.swift
//  Created by Vamshi krishna Padala on 22/01/19.
//  Copyright © 2019 Vamshi krishna Padala. All rights reserved.
//

import Foundation
import UIKit

//MARK: Image Extensions
extension UIImage {
	
	class func imageWithColor(color:UIColor, size:CGSize) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		let context = UIGraphicsGetCurrentContext()
		if context == nil {
			return nil
		}
		color.set()
		context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	
	class func verticalAppendedTotalImageSizeFromImagesArray(imagesArray:[UIImage]) -> CGSize {
		var totalSize = CGSize.zero
		for im in imagesArray {
			let imSize = im.size
			totalSize.height += imSize.height
			totalSize.width = max(totalSize.width, imSize.width)
		}
		return totalSize
	}
	
	
	class func verticalImageFromArray(imagesArray:[UIImage]) -> UIImage? {
		
		var unifiedImage:UIImage?
		let totalImageSize = self.verticalAppendedTotalImageSizeFromImagesArray(imagesArray: imagesArray)
		
		UIGraphicsBeginImageContextWithOptions(totalImageSize,false, 0)
		
		var imageOffsetFactor:CGFloat = 0
		
		for img in imagesArray {
			img.draw(at: CGPoint(x: 0, y: imageOffsetFactor))
			imageOffsetFactor += img.size.height
		}
		unifiedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return unifiedImage
	}
}

//MARK: Scrollview Extensions
extension UIScrollView {
	
	var screenshotOfVisibleContent : UIImage? {
		var croppingRect = self.bounds
		croppingRect.origin = self.contentOffset
		return self.screenshotForCroppingRect(croppingRect: croppingRect)
	}
	
}

// MARK: ****** Screenshot ****** Tableview Extensions
extension UITableView {
	
	var screenshotImage : UIImage? {
		return self.screenshotExcludingHeadersAtSections(excludedHeaderSections: nil, excludingFootersAtSections:nil, excludingRowsAtIndexPaths:nil)
	}
	
	func screenshotOfCellAtIndexPath(indexPath:NSIndexPath) -> UIImage? {
		var cellScreenshot:UIImage?
		
		let currTableViewOffset = self.contentOffset
		
		self.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
		
		cellScreenshot = self.cellForRow(at: indexPath as IndexPath)?.screenshot
		
		self.setContentOffset(currTableViewOffset, animated: false)
		
		return cellScreenshot
	}
	
	var screenshotOfHeaderView : UIImage? {
		let originalOffset = self.contentOffset
		if let headerRect = self.tableHeaderView?.frame {
			self.scrollRectToVisible(headerRect, animated: false)
			let headerScreenshot = self.screenshotForCroppingRect(croppingRect: headerRect)
			self.setContentOffset(originalOffset, animated: false)
			
			return headerScreenshot
		}
		return nil
	}
	
	var screenshotOfFooterView : UIImage? {
		let originalOffset = self.contentOffset
		if let footerRect = self.tableFooterView?.frame {
			self.scrollRectToVisible(footerRect, animated: false)
			let footerScreenshot = self.screenshotForCroppingRect(croppingRect: footerRect)
			self.setContentOffset(originalOffset, animated: false)
			
			return footerScreenshot
		}
		return nil
	}
	
	func screenshotOfHeaderViewAtSection(section:Int) -> UIImage? {
		let originalOffset = self.contentOffset
		let headerRect = self.rectForHeader(inSection: section)
		
		self.scrollRectToVisible(headerRect, animated: false)
		let headerScreenshot = self.screenshotForCroppingRect(croppingRect: headerRect)
		self.setContentOffset(originalOffset, animated: false)
		
		return headerScreenshot
	}
	
	func screenshotOfFooterViewAtSection(section:Int) -> UIImage? {
		let originalOffset = self.contentOffset
		let footerRect = self.rectForFooter(inSection: section)
		
		self.scrollRectToVisible(footerRect, animated: false)
		let footerScreenshot = self.screenshotForCroppingRect(croppingRect: footerRect)
		self.setContentOffset(originalOffset, animated: false)
		
		return footerScreenshot
	}
	
	
	func screenshotExcludingAllHeaders(withoutHeaders:Bool, excludingAllFooters:Bool, excludingAllRows:Bool) -> UIImage? {
		
		var excludedHeadersOrFootersSections:[Int]?
		
		if withoutHeaders || excludingAllFooters {
			excludedHeadersOrFootersSections = self.allSectionsIndexes
		}
		
		var excludedRows:[NSIndexPath]?
		
		if excludingAllRows {
			excludedRows = self.allRowsIndexPaths
		}
		
		return self.screenshotExcludingHeadersAtSections( excludedHeaderSections: withoutHeaders ? NSSet(array: excludedHeadersOrFootersSections!) : nil,
														  excludingFootersAtSections:excludingAllFooters ? NSSet(array:excludedHeadersOrFootersSections!) : nil, excludingRowsAtIndexPaths:excludingAllRows ? NSSet(array:excludedRows!) : nil)
	}
	
	func screenshotExcludingHeadersAtSections(excludedHeaderSections:NSSet?, excludingFootersAtSections:NSSet?,
											  excludingRowsAtIndexPaths:NSSet?) -> UIImage? {
		var screenshots = [UIImage]()
		
		if let headerScreenshot = self.screenshotOfHeaderView {
			screenshots.append(headerScreenshot)
		}
		
		for section in 0..<self.numberOfSections {
			if let headerScreenshot = self.screenshotOfHeaderViewAtSection(section: section, excludedHeaderSections: excludedHeaderSections) {
				screenshots.append(headerScreenshot)
			}
			
			for row in 0..<self.numberOfRows(inSection: section) {
				let cellIndexPath = NSIndexPath(row: row, section: section)
				if let cellScreenshot = self.screenshotOfCellAtIndexPath(indexPath: cellIndexPath) {
					screenshots.append(cellScreenshot)
				}
				
			}
			
			if let footerScreenshot = self.screenshotOfFooterViewAtSection(section: section, excludedFooterSections:excludingFootersAtSections) {
				screenshots.append(footerScreenshot)
			}
		}
		
		
		if let footerScreenshot = self.screenshotOfFooterView {
			screenshots.append(footerScreenshot)
		}
		
		return UIImage.verticalImageFromArray(imagesArray: screenshots)
		
	}
	
	func screenshotOfHeadersAtSections(includedHeaderSection:NSSet, footersAtSections:NSSet?, rowsAtIndexPaths:NSSet?) -> UIImage? {
		var screenshots = [UIImage]()
		
		for section in 0..<self.numberOfSections {
			if let headerScreenshot = self.screenshotOfHeaderViewAtSection(section: section, includedHeaderSections: includedHeaderSection) {
				screenshots.append(headerScreenshot)
			}
			
			for row in 0..<self.numberOfRows(inSection: section) {
				if let cellScreenshot = self.screenshotOfCellAtIndexPath(indexPath: NSIndexPath(row: row, section: section), includedIndexPaths: rowsAtIndexPaths) {
					screenshots.append(cellScreenshot)
				}
			}
			
			if let footerScreenshot = self.screenshotOfFooterViewAtSection(section: section, includedFooterSections: footersAtSections) {
				screenshots.append(footerScreenshot)
			}
		}
		
		return UIImage.verticalImageFromArray(imagesArray: screenshots)
	}
	
	func screenshotOfCellAtIndexPath(indexPath:NSIndexPath, excludedIndexPaths:NSSet?) -> UIImage? {
		if excludedIndexPaths == nil || !excludedIndexPaths!.contains(indexPath) {
			return nil
		}
		return self.screenshotOfCellAtIndexPath(indexPath: indexPath)
	}
	
	func screenshotOfHeaderViewAtSection(section:Int, excludedHeaderSections:NSSet?) -> UIImage? {
		if excludedHeaderSections != nil && !excludedHeaderSections!.contains(section) {
			return nil
		}
		
		var sectionScreenshot = self.screenshotOfHeaderViewAtSection(section: section)
		if sectionScreenshot == nil {
			sectionScreenshot = self.blankScreenshotOfHeaderAtSection(section: section)
		}
		return sectionScreenshot
	}
	
	func screenshotOfFooterViewAtSection(section:Int, excludedFooterSections:NSSet?) -> UIImage? {
		if excludedFooterSections != nil && !excludedFooterSections!.contains(section) {
			return nil
		}
		
		var sectionScreenshot = self.screenshotOfFooterViewAtSection(section: section)
		if sectionScreenshot == nil {
			sectionScreenshot = self.blankScreenshotOfFooterAtSection(section: section)
		}
		return sectionScreenshot
	}
	
	func screenshotOfCellAtIndexPath(indexPath:NSIndexPath, includedIndexPaths:NSSet?) -> UIImage? {
		if includedIndexPaths != nil && !includedIndexPaths!.contains(indexPath) {
			return nil
		}
		return self.screenshotOfCellAtIndexPath(indexPath: indexPath)
	}
	
	func screenshotOfHeaderViewAtSection(section:Int, includedHeaderSections:NSSet?) -> UIImage? {
		if includedHeaderSections != nil && !includedHeaderSections!.contains(section) {
			return nil
		}
		
		var sectionScreenshot = self.screenshotOfHeaderViewAtSection(section: section)
		if sectionScreenshot == nil {
			sectionScreenshot = self.blankScreenshotOfHeaderAtSection(section: section)
		}
		return sectionScreenshot
	}
	
	func screenshotOfFooterViewAtSection(section:Int, includedFooterSections:NSSet?)
		-> UIImage? {
			if includedFooterSections != nil && !includedFooterSections!.contains(section) {
				return nil
			}
			var sectionScreenshot = self.screenshotOfFooterViewAtSection(section: section)
			if sectionScreenshot == nil {
				sectionScreenshot = self.blankScreenshotOfFooterAtSection(section: section)
			}
			return sectionScreenshot
	}
	
	func blankScreenshotOfHeaderAtSection(section:Int) -> UIImage? {
		
		let headerRectSize = CGSize(width: self.bounds.size.width, height: self.rectForHeader(inSection: section).size.height)
		
		return UIImage.imageWithColor(color: UIColor.clear, size:headerRectSize)
	}
	
	func blankScreenshotOfFooterAtSection(section:Int) -> UIImage? {
		let footerRectSize = CGSize(width: self.bounds.size.width, height: self.rectForFooter(inSection: section).size.height)
		return UIImage.imageWithColor(color: UIColor.clear, size:footerRectSize)
	}
	
	var allSectionsIndexes : [Int] {
		let numSections = self.numberOfSections
		
		var allSectionsIndexes = [Int]()
		
		for section in 0..<numSections {
			allSectionsIndexes.append(section)
		}
		return allSectionsIndexes
	}
	
	
	var allRowsIndexPaths : [NSIndexPath] {
		var allRowsIndexPaths = [NSIndexPath]()
		for sectionIdx in self.allSectionsIndexes {
			for rowNum in 0..<self.numberOfRows(inSection: sectionIdx) {
				let indexPath = NSIndexPath(row: rowNum, section: sectionIdx)
				allRowsIndexPaths.append(indexPath)
			}
		}
		return allRowsIndexPaths
	}
	
	/*@IBAction func captureAction(_ sender: Any) {
	
	if let screenshotImage = self.tableView.screenshotImage {
	
	let pdfData = NSMutableData()
	UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: screenshotImage.size.width, height: screenshotImage.size.height), nil)
	UIGraphicsBeginPDFPage()
	screenshotImage.draw(in: CGRect(origin: .zero, size: screenshotImage.size))
	UIGraphicsEndPDFContext()
	
	let filename = contentId.uppercased()
	.replacingOccurrences(of: " - ", with: "_")
	.replacingOccurrences(of: "-", with: "_")
	.replacingOccurrences(of: "/", with: "_")
	.replacingOccurrences(of: ":", with: "_")
	.replacingOccurrences(of: " ", with: "_")
	
	print("captureAction: \(filename)")
	
	let _ = LocalFileManager.shared.saveDataFile(filename, data: pdfData as Data, fileExtension: "pdf")
	}
	}
	*/
	
}

//MARK: View Extensions
extension UIView {
	func screenshotForCroppingRect(croppingRect:CGRect) -> UIImage? {
		
		UIGraphicsBeginImageContextWithOptions(croppingRect.size, false, UIScreen.main.scale)
		
		let context = UIGraphicsGetCurrentContext()
		if context == nil {
			return nil
		}
		
		context!.translateBy(x: -croppingRect.origin.x, y: -croppingRect.origin.y)
		self.layoutIfNeeded()
		self.layer.render(in: context!)
		
		let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return screenshotImage
	}
	
	var screenshot : UIImage? {
		return self.screenshotForCroppingRect(croppingRect: self.bounds)
	}
}

//MARK: Location Extensions
public extension CLLocation {
	
	func reverseGeoCode(success:@escaping (CLPlacemark) -> Void, failure:@escaping (Error) -> Void) {
		
		//print("CLLocation.reverseGeoCode: \(self.coordinate.latitude, self.coordinate.longitude)")
		
		CLGeocoder().reverseGeocodeLocation(self, completionHandler: {(placemarks, error) -> Void in
			
			if error != nil {
				Logger.shared.log("Reverse geocoder failed with error: \(error!.localizedDescription)", level: .error)
				failure(error!)
				return
			}
			
			//print("Placemarks: \(placemarks!.count)")
			
			if placemarks!.count > 0 {
				
				let pm = placemarks![0]
				
				/*
				print(pm.name ?? "name: unknown")
				print(pm.subLocality ?? "subLocality: unknown")
				print(pm.locality ?? "locality: unknown")
				print(pm.administrativeArea ?? "administrativeArea: unknown")
				print(pm.postalCode ?? "postalCode: unknown")
				*/
				
				success(pm)
			}
			else {
				print("Error using data received from geocoder")
				let error = NSError(domain: "CLLocation", code: -1, userInfo: ["message" : "Problem with the data received from geocoder"])
				failure(error)
			}
		})
	}
}

// MARK: Date Extension
public extension Date {
	
	static let localeEnglishUS = Locale(identifier: "en_US_POSIX")
	
	// standard date formatter
	// handles: 2017-01-06T20:32:42.606Z and 1999-01-03T00:00:00.000-0500
	static func serverFormatter() -> DateFormatter {
		
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = localeEnglishUS
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		
		return formatter
	}
	
	// auxiliary data formatter
	// handles 2017-05-30T13:15:02-04:00
	static func serverFormatterAuxiliary() -> DateFormatter {
		
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = localeEnglishUS
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
		
		return formatter
	}
	
	// single instantiation of a date formatter (mm/dd/yyyy)
	static var dateFormatterUTC: DateFormatter {
		
		let formatter = DateFormatter()
		
		formatter.dateFormat = "MM/dd/yyyy"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Date.localeEnglishUS
		
		return formatter
	}
	
	// single instantiation of a date formatter (month day, year)
	static var dateFormatterUTCLonger: DateFormatter {
		
		let formatter = DateFormatter()
		
		formatter.dateFormat = "MMMM d, yyyy"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		formatter.locale = Date.localeEnglishUS
		
		return formatter
	}
	
	func stringForHuman() -> String {
		
		let formatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.long
		formatter.timeStyle = .long
		formatter.locale = Date.localeEnglishUS
		
		return formatter.string(from: self)
	}
	
	func stringDayMonthYearShort() -> String {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/dd/yyyy"
		formatter.locale = Date.localeEnglishUS
		
		return formatter.string(from: self)
	}
	
	static func dateFromString(mmddyyyy: String) -> Date {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/dd/yyyy"
		formatter.locale = Date.localeEnglishUS
		
		return formatter.date(from: mmddyyyy) ?? Date()
	}
	
	static func dateFromStringOptional(mmddyyyy: String) -> Date? {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/dd/yyyy"
		formatter.locale = Date.localeEnglishUS
		
		return formatter.date(from: mmddyyyy)
	}
	
	func stringForServer() -> String {
		
		let formatter = Date.serverFormatter()
		
		return formatter.string(from: self)
	}
	
	func stringTimeOnly() -> String {
		
		let formatter = DateFormatter()
		formatter.dateFormat = "hh:mm:ss.SSS a"
		formatter.locale = Date.localeEnglishUS
		
		return formatter.string(from: self)
	}
	
	static func dateFromServer(_ string: String) -> Date? {
		
		//print("dateFromServer: \(string)")
		
		guard string != "" else { return nil }
		
		let formatter = Date.serverFormatter()
		
		if let dateValue = formatter.date(from: string) {
			return dateValue
		} else if let dateValue = Date.serverFormatterAuxiliary().date(from: string) {
			//Logger.shared.log("dateFromServer: using auxiliary formatter: \(string), dateValue: \(dateValue.stringForHuman())", level: .debug)
			return dateValue
		} else {
			Logger.shared.log("dateFromServer: unexpected date format: \(string)", level: .error)
		}
		
		return nil
	}
	
	/*
	"Time ago" function for Swift (based on MatthewYork's DateTools for Objective-C) Swift 2
	https://gist.github.com/jacks205/4a77fb1703632eb9ae79
	*/
	func timeAgo(lowercase: Bool = false) -> String {
		
		let now = Date()
		
		// order this object's date to always be earlier than `now`
		let earliest = now < self ? now : self
		let latest = earliest == now ? self : now
		
		// get the calendar components
		let components: DateComponents = (Calendar.current as NSCalendar).components([
			NSCalendar.Unit.minute , NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second
			], from: earliest, to: latest, options: NSCalendar.Options())
		
		var text = "just now"
		
		if components.year! >= 2 {
			text = "\(components.year!) years ago"
			
		} else if components.year! >= 1 {
			text = "Last year"
			
		} else if components.month! >= 2 {
			text = "\(components.month!) months ago"
			
		} else if components.month! >= 1 {
			text = "Last month"
			
		} else if components.weekOfYear! >= 2 {
			text = "\(components.weekOfYear!) weeks ago"
			
		} else if components.weekOfYear! >= 1 {
			text = "Last week"
			
		} else if components.day! >= 2 {
			text = "\(components.day!) days ago"
			
		} else if components.day! >= 1 {
			text = "Yesterday"
			
		} else if components.hour! >= 2 {
			text = "\(components.hour!) hours ago"
			
		} else if components.hour! >= 1 {
			text = "An hour ago"
			
		} else if components.minute! >= 2 {
			text = "\(components.minute!) minutes ago"
			
		} else if components.minute! >= 1 {
			text = "A minute ago"
			
		} else if components.second! >= 3 {
			text = "\(components.second!) seconds ago"
		}
		
		return lowercase ? text.lowercased() : text
	}
}

//MARK: Dictionary Extension
extension Dictionary {
	
	// replaces values for existing keys, and adds key/value pairs for any new keys
	mutating func update(_ other: Dictionary) {
		
		for (key, value) in other {
			self.updateValue(value, forKey:key)
		}
	}
}

//MARK: Enum Extension
public protocol EnumCollection: Hashable {
	static func cases() -> AnySequence<Self>
	static var allValues: [Self] { get }
}

public extension EnumCollection {
	
	public static func cases() -> AnySequence<Self> {
		return AnySequence { () -> AnyIterator<Self> in
			var raw = 0
			return AnyIterator {
				let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
				guard current.hashValue == raw else {
					return nil
				}
				raw += 1
				return current
			}
		}
	}
	
	public static var allValues: [Self] {
		return Array(self.cases())
	}
}

//MARK: Double Extension
struct DoubleNumber {
	
	static let formatterWithSeparator: NumberFormatter = {
		
		// show thousand's separator
		let formatter = NumberFormatter()
		formatter.groupingSeparator = ","
		formatter.numberStyle = .decimal
		
		// truncate cents
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 0
		
		return formatter
	}()
	
	static let formatterWithCentsAndSeparator: NumberFormatter = {
		
		let formatter = NumberFormatter()
		
		// show thousand's separator
		formatter.groupingSeparator = ","
		formatter.numberStyle = .currency
		
		// show cents
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		
		return formatter
	}()
}

public extension Double {
	
	var formattedWithSeparator: String {
		return DoubleNumber.formatterWithSeparator.string(from: self as NSNumber) ?? ""
	}
	
	var formatted2Places: String {
		return String(format: "%.2f", locale: Locale.current, self)
	}
	
	var formattedWithCentsAndSeparator: String {
		return DoubleNumber.formatterWithCentsAndSeparator.string(from: self as NSNumber) ?? ""
	}
}

//MARK: Encryption Extension
extension String {
	
	//
	// encrypt with key (random salt in header position, data in body position)
	//
	func encrypt(key: Data) -> Data {
		
		return encrypt(password: String(data: key.base64EncodedData(), encoding: .utf8)!)
	}
	
	//
	// encrypt with password (random salt in header position, data in body position)
	//
	func encrypt(password: String ) -> Data {
		
		let message = self.data(using: .utf8)!
		
		let cipherText: NSData = {
			
			func randomSaltAndKeyForPassword(_ password: String) -> (salt: NSData, key: NSData) {
				let salt = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.saltSize)
				let key = RNCryptor.FormatV3.makeKey(forPassword: password, withSalt: salt)
				return (salt as NSData, key as NSData)
			}
			
			let (encryptionSalt, encryptionKey) = randomSaltAndKeyForPassword(password)
			let (hmacSalt, hmacKey) = randomSaltAndKeyForPassword(password)
			let encryptor = RNCryptor.EncryptorV3(encryptionKey: encryptionKey as Data, hmacKey: hmacKey as Data)
			
			let cipherText = NSMutableData(data: encryptionSalt as Data)
			cipherText.append(hmacSalt as Data)
			cipherText.append(encryptor.encrypt(data: message))
			
			return cipherText
		}()
		
		return cipherText as Data
	}
	
	// generate PBKDF2 (10K rounds) hash of this string with salt
	func hashed(salt: Data) -> Data {
		
		let hashed = RNCryptor.FormatV3.makeKey(forPassword: self, withSalt: salt)
		
		return hashed
	}
	
	// return the concantenate string: "self•other"
	func bulletConcat(other: String) -> String {
		
		return "\(self)•\(other)"
	}
}

extension Data {
	
	//
	// decrypt with key (salt in header position, data in body position)
	//
	func decrypt(key: Data) -> String? {
		
		return decrypt(password: String(data: key.base64EncodedData(), encoding: .utf8)!)
	}
	
	//
	// decrypt with password (salt in header position, data in body position)
	//
	func decrypt(password: String) -> String? {
		
		let cipherText = NSData(data: self)
		
		let plainText: NSData? = {
			
			let encryptionSaltRange = NSRange(location: 0, length: RNCryptor.FormatV3.saltSize)
			let hmacSaltRange = NSRange(location: NSMaxRange(encryptionSaltRange), length: RNCryptor.FormatV3.saltSize)
			let bodyRange = NSRange(NSMaxRange(hmacSaltRange)..<cipherText.length)
			
			let encryptionSalt = cipherText.subdata(with: encryptionSaltRange)
			let hmacSalt = cipherText.subdata(with: hmacSaltRange)
			let body = cipherText.subdata(with: bodyRange)
			
			let encryptionKey = RNCryptor.FormatV3.makeKey(forPassword: password, withSalt: encryptionSalt)
			let hmacKey = RNCryptor.FormatV3.makeKey(forPassword: password,withSalt: hmacSalt)
			
			do {
				return try RNCryptor.DecryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
					.decrypt(data: body) as NSData
			} catch {
				return nil
			}
		}()
		
		guard plainText != nil else { return nil }
		
		return String(data: plainText! as Data, encoding: .utf8)!
	}
}

//MARK: Integer Extension
struct IntegerNumber {
	
	static let formatterWithSeparator: NumberFormatter = {
		
		let formatter = NumberFormatter()
		formatter.groupingSeparator = ","
		formatter.numberStyle = .decimal
		
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 0
		
		return formatter
	}()
}

public extension BinaryInteger {
	
	var formattedWithSeparator: String {
		
		return IntegerNumber.formatterWithSeparator.string(from: self as! NSNumber) ?? ""
	}
}

//MARK: String Extension
public extension String {
	
	static let alphaNumericChars256Length = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefgh"
	
	subscript(pos: Int) -> String {
		precondition(pos >= 0, "character position can't be negative")
		return self[pos...pos]
	}
	
	subscript(range: Range<Int>) -> String {
		precondition(range.lowerBound >= 0, "range lowerBound can't be negative")
		let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? endIndex
		return String(self[lowerIndex..<(index(lowerIndex, offsetBy: range.count, limitedBy: endIndex) ?? endIndex)])
	}
	
	subscript(range: ClosedRange<Int>) -> String {
		precondition(range.lowerBound >= 0, "range lowerBound can't be negative")
		let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? endIndex
		return String(self[lowerIndex..<(index(lowerIndex, offsetBy: range.count, limitedBy: endIndex) ?? endIndex)])
	}
	
	func truncated(_ maxLength: Int) -> String {
		return String(prefix(maxLength))
	}
	
	//
	//  © George Andrews 10/22/16
	//
	//	http://www.iteachcoding.com/how-to-hmac-sha1-sign-an-api-request-using-swift/
	//
	func hmacsha1(key: String) -> Data {
		
		let dataToDigest = self.data(using: String.Encoding.utf8)
		let keyData = key.data(using: String.Encoding.utf8)
		
		let digestLength = Int(CC_SHA1_DIGEST_LENGTH)
		let result = UnsafeMutablePointer<Any>.allocate(capacity: digestLength)
		
		CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), (keyData! as NSData).bytes, keyData!.count, (dataToDigest! as NSData).bytes, dataToDigest!.count, result)
		
		return Data(bytes: UnsafePointer(result), count: digestLength)
	}
	
	var trimmed: String {
		return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
	func stringByAddingPercentEncodingForRFC3986() -> String? {
		
		let unreserved = "-._~/?"
		
		let allowed = NSMutableCharacterSet.alphanumeric()
		allowed.addCharacters(in: unreserved)
		
		return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
	}
	
	// return true if this string contains any of strings in the array (case-insensitve)
	func matches(strings: [String]) -> Bool {
		
		return strings.filter({ self.lowercased().contains($0.lowercased()) }).count > 0
	}
	
	var html2AttributedString: NSAttributedString? {
		
		guard let data = data(using: .utf8) else { return nil }
		
		do {
			return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
		} catch let error as NSError {
			Logger.shared.log("html2AttributedString: error: \(error.localizedDescription)", level: .error)
			return  nil
		}
	}
	
	var html2String: String {
		return html2AttributedString?.string ?? ""
	}
	
	// return a string of securely generated random alpha-numeric characters of length `count`
	static func secureRandomAlphaNumeric(count: Int = 20) -> String {
		
		// securely generate random bytes of length `count`
		var data = Data(count: count)
		let result = data.withUnsafeMutableBytes { return SecRandomCopyBytes(kSecRandomDefault, count, $0) }
		
		guard result == errSecSuccess else {
			fatalError("could not generate secure random alphanumberic: \(result).")
		}
		
		// map the bytes to alphanumeric characters
		var randomString = ""
		
		for byte in data {
			let index = alphaNumericChars256Length.index(alphaNumericChars256Length.startIndex, offsetBy: Int(byte))
			randomString += String(alphaNumericChars256Length[index])
		}
		
		//Logger.shared.log("secureRandomAlphaNumeric: \(randomString)", level: .debug)
		
		return randomString
	}
	
	// return an attributed string by applying app font of `fontSize` to the first occurrence of any special characters (®, ™, etc)
	func attributedWithSpecialCharacters(fontSize: CGFloat) -> NSAttributedString {
		return NSAttributedString(string: self).attributedWithSpecialCharacters(fontSize: fontSize)
	}
	
	func capitalizingFirstLetter() -> String {
		return prefix(1).uppercased() + dropFirst()
	}
	
	func lowercasingFirstLetter() -> String {
		return prefix(1).lowercased() + dropFirst()
	}
	
	var camelCasedString: String {
		
		let camelCased = self.components(separatedBy: " ").map { return $0.lowercased().capitalizingFirstLetter() }.joined()
		return camelCased.lowercasingFirstLetter()
	}
	
	// return a string containing the first and last letter of the left-hand side of the email address with 4 asterisks in the middle plus the full right-hand side of the email address
	// minimum parseable address: a@b.by (6 chars)
	func obfuscateEmailAddress() -> String {
		
		guard self.count >= 6 else {
			// invalid format, return the input
			return self
		}
		
		let parts = self.components(separatedBy: "@")
		
		guard parts.count >= 2 else {
			// invalid format, return the input
			return self
		}
		
		let beforeAt = parts[0]
		let afterAt = parts[1]
		
		guard beforeAt.count >= 3 else {
			
			// not enough characters before the @ sign, return ****@foo.com
			return "****@\(afterAt)"
		}
		
		let firstCharacter = beforeAt[0]
		let lastCharacter = beforeAt[beforeAt.count - 1]
		
		// return first and last letter of the left-hand side of the email address with 4 asterisks in the middle plus the full right-hand side of the email address
		let obfuscated = "\(firstCharacter)****\(lastCharacter)@\(afterAt)"
		
		// lowercase everything
		return obfuscated.lowercased()
	}
	
	//
	// https://github.com/DragonCherry/VersionCompare
	// Inner comparison utility to handle same versions with different length. (Ex: "1.0.0" & "1.0")
	//
	private func compare(toVersion targetVersion: String) -> ComparisonResult {
		
		let versionDelimiter = "."
		var result: ComparisonResult = .orderedSame
		var versionComponents = components(separatedBy: versionDelimiter)
		var targetComponents = targetVersion.components(separatedBy: versionDelimiter)
		let spareCount = versionComponents.count - targetComponents.count
		
		if spareCount == 0 {
			result = compare(targetVersion, options: .numeric)
		} else {
			let spareZeros = repeatElement("0", count: abs(spareCount))
			if spareCount > 0 {
				targetComponents.append(contentsOf: spareZeros)
			} else {
				versionComponents.append(contentsOf: spareZeros)
			}
			result = versionComponents.joined(separator: versionDelimiter)
				.compare(targetComponents.joined(separator: versionDelimiter), options: .numeric)
		}
		return result
	}
	
	public func isVersion(equalTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedSame }
	public func isVersion(greaterThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedDescending }
	public func isVersion(greaterThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedAscending }
	public func isVersion(lessThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedAscending }
	public func isVersion(lessThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedDescending }
}

//MARK: Application Extension
extension UIApplication {
	
	class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
		
		if let navigationController = controller as? UINavigationController {
			return topViewController(controller: navigationController.visibleViewController)
		}
		
		if let tabController = controller as? UITabBarController {
			if let selected = tabController.selectedViewController {
				return topViewController(controller: selected)
			}
		}
		
		if let presented = controller?.presentedViewController {
			return topViewController(controller: presented)
		}
		
		return controller
	}
}

extension UIApplication.State {
	
	var description: String {
		
		switch self {
		case .active: return "active"
		case .inactive: return "inactive"
		case .background: return "background"
		}
	}
}

//MARK: Button Extension
public extension UIButton {
	
	// set the background color of a button (using a dynamic image)
	func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
		
		UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
		UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
		UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
		let colorImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		self.setBackgroundImage(colorImage, for: forState)
	}
}

//MARK: Color Extension
extension UIColor {
	
	func toUInt() -> UInt {
		
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		
		if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
			
			let uint = UInt32(red * 255.0) << 16 + UInt32(green * 255.0) << 8 + UInt32(blue * 255.0)
			
			return UInt(uint)
		}
		
		return 0x000000
	}
	
	// https://stackoverflow.com/questions/38435308/get-lighter-and-darker-color-variations-for-a-given-uicolor
	/**
	Create a ligher color
	*/
	func lighter(by percentage: CGFloat = 30.0) -> UIColor {
		return self.adjustBrightness(by: abs(percentage))
	}
	
	/**
	Create a darker color
	*/
	func darker(by percentage: CGFloat = 30.0) -> UIColor {
		return self.adjustBrightness(by: -abs(percentage))
	}
	
	/**
	Try to increase brightness or decrease saturation
	*/
	func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
		var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
			if b < 1.0 {
				let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0.0)
				return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
			} else {
				let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
				return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
			}
		}
		return self
	}
}

//MARK: View Extension
extension UIView {
	
	// fades rely on isHidden and alpha states initialized correctly
	func prepareForFade() {
		
		self.isHidden = true
		self.alpha = 0.0
	}
	
	// fade in if not already visible or tranitioning to visible
	func fadeIn(immediately: Bool = false) {
		
		if !self.isHidden || self.alpha > 0.0 { return }
		
		if immediately {
			
			self.alpha = 1.0
			self.isHidden = false
			return
		}
		
		//print("fadeIn")
		
		self.isHidden = false
		self.alpha = 0.0
		self.layer.removeAllAnimations()
		
		UIView.animate(withDuration: 0.4, animations: {
			
			self.alpha = 1.0
			
		}, completion: { finished in
			self.alpha = 1.0
		})
	}
	
	// fade in if not already hidden or tranitioning to hidden
	func fadeOut(immediately: Bool = false) {
		
		if self.isHidden || self.alpha < 1.0 { return }
		
		if immediately {
			
			self.alpha = 0.0
			self.isHidden = true
			return
		}
		
		//print("fadeOut")
		
		self.alpha = 1.0
		self.layer.removeAllAnimations()
		
		UIView.animate(withDuration: 0.4, animations: {
			
			self.alpha = 0.0
			
		}, completion: { finished in
			self.isHidden = true
			self.alpha = 0.0
		})
	}
	
	func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
		
		let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		self.layer.mask = mask
	}
	
	func fadeTransition(_ duration:CFTimeInterval) {
		
		let animation = CATransition()
		
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		animation.type = CATransitionType.fade
		animation.duration = duration
		layer.add(animation, forKey: CATransitionType.fade.rawValue)
	}
}

//MARK: ViewController Extension
extension UIViewController: SFSafariViewControllerDelegate {
	
	enum BrowserMethod {
		case embedded, nativeApp
	}
	
	var appDelegate : AppDelegate {
		return AppDelegate.shared
	}
	
	//
	// open a url for a tracked link in a safari view controller (presented in-app, not kicking out to Safari.app)
	// presentations are tracked in app delegate using this method for later manual closing
	//
	func openInSafariViewController(_ trackedLink: TrackedLink) {
		openInSafariViewController(trackedLink.tracked)
	}
	
	//
	// open a url in a safari view controller (presented in-app, not kicking out to Safari.app)
	// presentations are tracked in app delegate using this method for later manual closing
	//
	func openInSafariViewController(_ urlString: String) {
		
		guard urlString.lowercased().starts(with: "http") else {
			
			Logger.shared.log("openInSafariViewController: cannot open \(urlString) because it does not start with \"http\"", level: .error)
			return
		}
		
		if let url = URL(string: urlString) {
			
			Logger.shared.log("\nopenInSafariViewController:\n\n\(urlString)\n", level: .debug)
			
			let safariVC = SFSafariViewController(url: url)
			
			let tintColor = Constants.AppColor.bcbsaBlue
			
			if #available(iOS 10.0, *) {
				safariVC.preferredControlTintColor = tintColor
			} else {
				safariVC.view.tintColor = tintColor
			}
			
			safariVC.delegate = self
			
			// let app delegate track this
			appDelegate.currentSafariViewContoller = safariVC
			
			self.present(safariVC, animated: true, completion: nil)
		}
	}
	
	//
	// tell the app delegate to unset the current safari view controller
	//
	public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		
		// let app delegate know to stop tracking this
		appDelegate.currentSafariViewContoller = nil
	}
	
	// convenience method for instantiating a timer with `timeInterval` and `selector`
	func scheduledTimer(_ timeInterval: Double, selector: Selector) -> Timer {
		return Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: selector, userInfo: nil, repeats: false)
	}
	
	// return the name of this VC's class
	var className: String {
		return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last ?? NSStringFromClass(self.classForCoder)
	}
	
	// open an SSO link
	//todo: add optional competion and error handlers
	func openSsoLink(url: String, browserMethod: BrowserMethod = .embedded) {
		
		NVActivityIndicatorPresenter.sharedInstance.startAnimating(Constants.AppDefaults.activityPresenterSettings, Constants.AppDefaults.fadeInAnimation)
		
		RequestManager.shared.getSSOToken(completion: { fepTokenKey in
			
			NVActivityIndicatorPresenter.sharedInstance.stopAnimating(Constants.AppDefaults.fadeOutAnimation)
			
			//print("got fepTokenKey: \(fepTokenKey)")
			
			// percent-encode the notification link
			var allowedCharacters: CharacterSet = .alphanumerics
			allowedCharacters = allowedCharacters.union(CharacterSet(charactersIn: "."))
			let escapedNotificationUrl = url.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
			
			// start building the URL with the SSO endpoint
			var urlString = DataConstants.Endpoints.Params.SSO.ssoURL
			
			let baseUrl = "\(UrlSwizzler.shared.swizzleAppServer(forceSwizzle: true))"
			
			// inject the token and the notification link
			urlString = urlString.replacingOccurrences(of: DataConstants.Endpoints.Params.SSO.fepTokenKeyParam, with: fepTokenKey)
			urlString = urlString.replacingOccurrences(of: DataConstants.Endpoints.Params.SSO.ssoUrlParam, with: escapedNotificationUrl)
			urlString = "\(baseUrl)\(urlString)"
			
			Logger.shared.log("openSsoLink: url:\n\(url)\nssoLink:\n\(urlString)", level: .debug)
			
			if browserMethod == .embedded {
				// open the final URL in a safari view controller
				self.openInSafariViewController(urlString)
				
			} else {
				self.appDelegate.open(urlString: urlString)
			}
			
		}, errorHandler: { dataError in
			
			AppDelegate.afterDelay(0.2) {
				NVActivityIndicatorPresenter.sharedInstance.stopAnimating(Constants.AppDefaults.fadeOutAnimation)
			}
			
			Logger.shared.log("error getting fep token key for sso: \(dataError.description)", level: .error)
			
			AppDelegate.afterDelay(0.4) {
				AlertPresenter.shared.showBasicAlertTitle(UserMessages.SsoError.title, subtitle: UserMessages.SsoError.subtitle)
			}
		})
	}
}

//MARK: Device Extension
extension UIDevice {
	
	var modelName: String {
		
		var systemInfo = utsname()
		uname(&systemInfo)
		
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		
		switch identifier {
			
		// iPod Touch
		case "iPod5,1":										return "iPod Touch 5"
		case "iPod7,1":										return "iPod Touch 6"
			
		// iPhone
		case "iPhone3,1", "iPhone3,2", "iPhone3,3":			return "iPhone 4"
		case "iPhone4,1":									return "iPhone 4s"
		case "iPhone5,1", "iPhone5,2":						return "iPhone 5"
		case "iPhone5,3", "iPhone5,4":						return "iPhone 5c"
		case "iPhone6,1", "iPhone6,2":						return "iPhone 5s"
		case "iPhone7,2":									return "iPhone 6"
		case "iPhone7,1":									return "iPhone 6 Plus"
		case "iPhone8,1":									return "iPhone 6s"
		case "iPhone8,2":									return "iPhone 6s Plus"
		case "iPhone8,4":									return "iPhone SE"
		case "iPhone9,1", "iPhone9,3":						return "iPhone 7"
		case "iPhone9,2", "iPhone9,4":						return "iPhone 7 Plus"
		case "iPhone10,1", "iPhone10,4":                	return "iPhone 8"
		case "iPhone10,2", "iPhone10,5":                	return "iPhone 8 Plus"
		case "iPhone10,3", "iPhone10,6":                	return "iPhone X"
			
		// new models as of Oct, 2018
		case "iPhone11,2":                					return "iPhone XS"
		case "iPhone11,4", "iPhone11,6":                	return "iPhone XS Max"
		case "iPhone11,8":                					return "iPhone XR"
			
		// iPad
		case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":	return "iPad 2"
		case "iPad3,1", "iPad3,2", "iPad3,3":				return "iPad 3"
		case "iPad3,4", "iPad3,5", "iPad3,6":				return "iPad 4"
		case "iPad4,1", "iPad4,2", "iPad4,3":				return "iPad Air"
		case "iPad5,3", "iPad5,4":							return "iPad Air 2"
		case "iPad2,5", "iPad2,6", "iPad2,7":				return "iPad Mini"
		case "iPad4,4", "iPad4,5", "iPad4,6":				return "iPad Mini 2"
		case "iPad4,7", "iPad4,8", "iPad4,9":				return "iPad Mini 3"
		case "iPad5,1", "iPad5,2":							return "iPad Mini 4"
		case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":	return "iPad Pro"
			
		// other
		case "AppleTV5,3":									return "Apple TV"
		case "i386", "x86_64":								return Switch.simluatorIsiPhoneX == .on ? "iPhone X" : "Simulator"
		default:											return identifier
		}
	}
}

// MARK: Attributed String Extension
public extension NSAttributedString {
	
	/// SwifterSwift: Applies given attributes to the new instance of NSAttributedString initialized with self object
	///
	/// - Parameter attributes: Dictionary of attributes
	/// - Returns: NSAttributedString with applied attributes
	fileprivate func applying(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
		let copy = NSMutableAttributedString(attributedString: self)
		let range = (string as NSString).range(of: string)
		copy.addAttributes(attributes, range: range)
		
		return copy
	}
	
	/// SwifterSwift: Apply attributes to substrings matching a regular expression
	///
	/// - Parameters:
	///   - attributes: Dictionary of attributes
	///   - pattern: a regular expression to target
	/// - Returns: An NSAttributedString with attributes applied to substrings matching the pattern
	public func applying(attributes: [NSAttributedString.Key: Any], toRangesMatching pattern: String) -> NSAttributedString {
		
		guard let pattern = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
		
		let matches = pattern.matches(in: string, options: [], range: NSRange(0..<length))
		let result = NSMutableAttributedString(attributedString: self)
		
		for match in matches {
			result.addAttributes(attributes, range: match.range)
		}
		
		return result
	}
	
	/// SwifterSwift: Apply attributes to occurrences of a given string
	///
	/// - Parameters:
	///   - attributes: Dictionary of attributes
	///   - target: a subsequence string for the attributes to be applied to
	/// - Returns: An NSAttributedString with attributes applied on the target string
	public func applying<T: StringProtocol>(attributes: [NSAttributedString.Key: Any], toOccurrencesOf target: T) -> NSAttributedString {
		let pattern = "\\Q\(target)\\E"
		
		return applying(attributes: attributes, toRangesMatching: pattern)
	}
	
	// added by rob
	// return an attributed string by applying a smaller font and adjusted baseline to occurrences of "®"
	func attributedWithSpecialCharacters(fontSize: CGFloat) -> NSAttributedString {
		return self.applying(attributes: [
			.font: AppFontManager.appFont(.regular, size: fontSize * 0.667),
			.baselineOffset: fontSize * 0.25], toOccurrencesOf: "®")
	}
}

//MARK: Mutable Attributed String Extension
extension NSMutableAttributedString {
	
	@discardableResult func bold(_ text: String, of size: CGFloat = 17.0) -> NSMutableAttributedString {
		
		let fontAttributes:[NSAttributedString.Key : AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : AppFontManager.appFont(.bold, size: size)]
		
		let boldString = NSMutableAttributedString(string:"\(text)", attributes: fontAttributes)
		
		self.append(boldString)
		
		return self
	}
	
	@discardableResult func normal(_ text: String, of size: CGFloat = 17.0) -> NSMutableAttributedString {
		
		let fontAttributes:[NSAttributedString.Key : AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : AppFontManager.appFont(.regular, size: size)]
		
		let normal = NSAttributedString(string: "\(text)", attributes: fontAttributes)
		
		self.append(normal)
		
		return self
	}
}

extension NSAttributedString {
	
	func height(withConstrainedWidth width: CGFloat) -> CGFloat {
		
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
		
		return ceil(boundingBox.height)
	}
	
	func width(withConstrainedHeight height: CGFloat) -> CGFloat {
		
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
		
		return ceil(boundingBox.width)
	}
}

// MARK: Label Extension
extension UILabel {
	
	// underline this label with a dot pattern using `color` (preserves the currently set font and foreground color)
	func underliningInColor(_ color: UIColor) {
		
		if let currentText = self.text {
			
			let attributes: [NSAttributedString.Key : Any] = [
				
				.underlineColor: color,
				.underlineStyle: NSUnderlineStyle.single.rawValue | NSUnderlineStyle.patternDot.rawValue,
				.foregroundColor: self.textColor,
				.font: self.font
			]
			
			// replace the current text with attributed text using the above attributes
			self.attributedText = NSAttributedString(string: currentText, attributes: attributes)
		}
	}
}

// MARK: Textfield Extension
extension UITextField {
	
	// toggles secure entry on the textfield and compensates for the transition
	func togglePasswordVisibility() {
		
		isSecureTextEntry = !isSecureTextEntry
		
		if let existingText = text, isSecureTextEntry {
			
			// going from insecure to secure: delete the current text and put it back or it will be cleared
			deleteBackward()
			
			if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
				replace(textRange, withText: existingText)
			}
			
		} else {
			
			// going from secure to insecure: workaround to reposition the cursor after toggling
			let currentText = self.text
			self.text = nil
			self.text = currentText
		}
	}
}

// MARK: CALayer Extension
extension CALayer {
	
	func addBorders(edges: UIRectEdge = .all, color: UIColor, thickness: CGFloat) {
		
		if edges == .all || edges.contains(.top) {
			addBorder(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: thickness), color: color)
		}
		
		if edges == .all || edges.contains(.bottom) {
			addBorder(frame: CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness), color: color)
		}
		
		if edges == .all || edges.contains(.left) {
			addBorder(frame: CGRect(x: 0, y: 0, width: thickness, height: self.frame.height), color: color)
		}
		
		if edges == .all || edges.contains(.right) {
			addBorder(frame: CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height), color: color)
		}
	}
	
	private func addBorder(frame: CGRect, color: UIColor) {
		
		let border = CALayer()
		
		border.frame = frame
		border.backgroundColor = color.cgColor
		
		self.addSublayer(border)
	}
}

