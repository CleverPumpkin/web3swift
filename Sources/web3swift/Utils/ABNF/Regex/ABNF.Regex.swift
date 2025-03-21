//
//  ABNF.Regex.swift
//  Web3swift
//
//  Created by Nikita Tarkhov on 21.03.2025.
//

import Foundation

extension ABNF {
	struct Regex: Sendable {
		
		// MARK: - Internal properties
		
		let pattern: String
		
		// MARK: - Initialization
		
		init(_ pattern: String) {
			self.pattern = pattern
		}
	}
}

// MARK: - CustomStringConvertible

extension ABNF.Regex: CustomStringConvertible {
	
	// MARK: - Internal properties
	
	var description: String {
		pattern
	}
}

// MARK: - Default values

extension ABNF.Regex {
	
	// MARK: - Internal static properties
	
	static let unreserved = Self(
		"[a-zA-Z0-9\\-._~]"
	)

	static let pctEncoded = Self(
		"%[0-9A-Fa-f][0-9A-Fa-f]"
	)

	static let subDelims = Self(
		"[!$&'()*+,;=]"
	)

	static let userinfo = Self(
		"(\(unreserved)|\(pctEncoded)|\(subDelims)|:)*"
	)

	static let h16 = Self(
		"[0-9A-Fa-f]{1,4}"
	)

	static let decOctet = Self(
		"([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
	)

	static let ipv4address = Self(
		"\(decOctet)\\.\(decOctet)\\.\(decOctet)\\.\(decOctet)"
	)

	static let ls32 = Self(
		"(\(h16):\(h16)|\(ipv4address))"
	)

	static let ipv6address = Self(
		"((\(h16):){6}\(ls32)|::(\(h16):){5}\(ls32)|(\(h16))?::(\(h16):){4}\(ls32)|((\(h16):)?\(h16))?::(\(h16):){3}\(ls32)|((\(h16):){2}\(h16))?::(\(h16):){2}\(ls32)|((\(h16):){3}\(h16))?::\(h16):\(ls32)|((\(h16):){4}\(h16))?::\(ls32)|((\(h16):){5}\(h16))?::\(h16)|((\(h16):){6}\(h16))?::)"
	)

	static let ipvfuture = Self(
		"[vV][0-9A-Fa-f]+\\.(\(unreserved)|\(subDelims)|:)+"
	)

	static let ipLiteral = Self(
		"\\[(\(ipv6address)|\(ipvfuture))\\]"
	)

	static let regName = Self(
		"(\(unreserved)|\(pctEncoded)|\(subDelims))*"
	)

	static let host = Self(
		"(\(ipLiteral)|\(ipv4address)|\(regName))"
	)

	static let port = Self(
		"[0-9]*"
	)

	static let authority = Self(
		"(\(userinfo)@)?\(host)(:\(port))?"
	)

	static let dateFullyear = Self(
		"[0-9]{4}"
	)

	static let dateMday = Self(
		"[0-9]{2}"
	)

	static let dateMonth = Self(
		"[0-9]{2}"
	)

	static let fullDate = Self(
		"\(dateFullyear)-\(dateMonth)-\(dateMday)"
	)

	static let timeHour = Self(
		"[0-9]{2}"
	)

	static let timeMinute = Self(
		"[0-9]{2}"
	)

	static let timeSecond = Self(
		"[0-9]{2}"
	)

	static let timeSecfrac = Self(
		"\\.[0-9]+"
	)

	static let partialTime = Self(
		"\(timeHour):\(timeMinute):\(timeSecond)(\(timeSecfrac))?"
	)

	static let timeNumoffset = Self(
		"[+\\-]\(timeHour):\(timeMinute)"
	)

	static let timeOffset = Self(
		"([zZ]|\(timeNumoffset))"
	)

	static let fullTime = Self(
		"\(partialTime)\(timeOffset)"
	)

	static let dateTime = Self(
		"\(fullDate)[tT]\(fullTime)"
	)

	static let pchar = Self(
		"(\(unreserved)|\(pctEncoded)|\(subDelims)|[:@])"
	)

	static let fragment = Self(
		"(\(pchar)|[/?])*"
	)

	static let genDelims = Self(
		"[:/?#\\[\\]@]"
	)

	static let segment = Self(
		"(\(pchar))*"
	)

	static let pathAbempty = Self(
		"(/\(segment))*"
	)

	static let segmentNz = Self(
		"(\(pchar))+"
	)

	static let pathAbsolute = Self(
		"/(\(segmentNz)(/\(segment))*)?"
	)

	static let pathRootless = Self(
		"\(segmentNz)(/\(segment))*"
	)

	static let pathEmpty = Self(
		"(\(pchar)){0}"
	)

	static let hierPart = Self(
		"(//\(authority)\(pathAbempty)|\(pathAbsolute)|\(pathRootless)|\(pathEmpty))"
	)

	static let query = Self(
		"(\(pchar)|[/?])*"
	)

	static let reserved = Self(
		"(\(genDelims)|\(subDelims))"
	)
}

// MARK: - Convenience

extension String {
	
	// MARK: - Internal methods
	
	func isValid(regex: ABNF.Regex) -> Bool {
		do {
			let regularExpression = try NSRegularExpression(pattern: "^\(regex.pattern)$")
			
			let numberOfMatches = regularExpression
				.numberOfMatches(
					in: self,
					range: NSRange(startIndex..., in: self)
				)
			
			return numberOfMatches > 0
		} catch {
			return false
		}
	}
}
