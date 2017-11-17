//
//  main.swift
//  Project
//
//  Created by Eric Ferreira on 11/11/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public struct StderrOutputStream: TextOutputStream {
	public mutating func write(_ string: String) { fputs(string, stderr) }
}

public var errStream = StderrOutputStream()

func read() -> String {
	fflush(stdout)

	let data = FileHandle.standardInput.availableData
	let string = String(data: data, encoding: String.Encoding.utf8)!

	return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
}

func readFrom(_ file: String) -> String? {
	#if os(Linux)
		let fp = fopen(file, "r")
		
		if fp != nil {
			let BUFSIZE = 1024
			
			var content = ""
			var buf = [CChar](repeating: CChar(0), count: BUFSIZE)
			
			while fgets(&buf, Int32(BUFSIZE), fp) != nil {
				content += String(cString: buf)
			}
			
			return content
		} else {
			return nil
		}
	#else
		return try? String(contentsOfFile: file)
	#endif
}

#if os(Linux)
	srandom(UInt32(time(nil)))
#endif

enum Next {
	case next
	case same
	case last
}

struct Menu {
	let printMenu: () -> Void
	let isValid: (String) -> Bool
	let action: (String) -> Next
}

func prompt(_ menus: Menu..., loop: Bool = false) -> Next {
	repeat {
		var i = 0

		while i < menus.count {
			if i < 0 {
				return .same
			}

			let menu = menus[i]

			menu.printMenu()
			print(", b to go back, or q to quit: ", terminator: "")

			let input = read()
			print()

			if input == "q" {
				exit(0)
			} else if i >= 0 && input == "b" {
				i -= 1

				continue
			}

			guard menu.isValid(input) else {
				print("That wasn't a valid input!\n")
				continue
			}

			switch menu.action(input) {
			case .next:
				i += 1
			case .last:
				i -= 1
			case .same:
				break
			}
		}
	} while loop

	return .next
}

func runRscript(_ args: String...) -> Next {
	let task = Process()
	
	task.launchPath = "Rscript-proxy.sh"
	task.arguments = args
	
	let standard = Pipe()
	let error = Pipe()
	
	task.standardOutput = standard
	task.standardError = error
	
	task.launch()
	task.waitUntilExit()
	
	if let errorText = String(data: error.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), errorText.count > 0 && task.terminationStatus != 0 {
		print("There was an error during the automatic execution of the R script:")
		print("-- \(errorText) --")
		print("Let's try this the old fashioned way...")
		print()
		
		return prompt(Menu(printMenu: {
			let joined = args.map { "\"\($0)\"" }.joined(separator: " ")
			
			print("Please open a terminal in the \"Source Code\" directory and run: Rscript \(joined)")
			print("When it is done executing, please return here and hit enter", terminator: "")
		}, isValid: {_ in true}, action: {_ in .next}))
	}

	return .next
}

_ = prompt(Menu(printMenu: {
	print("Which problem are you working on? Enter 1-3", terminator: "")
}, isValid: {input in
	return 1...3 ~= (Int(input) ?? -1)
}, action: {problem in
	switch problem {
	case "1":
		return problemOne()
	case "2":
		return problemTwo()
	case "3":
		return problemThree()
	default:
		return .next
	}
}), loop: true)
