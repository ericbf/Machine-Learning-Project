//
//  problem-two.swift
//  Project
//
//  Created by Eric Ferreira on 11/15/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation

func problemTwo() -> Next {
	var set = -1
	
	return prompt(Menu(printMenu: {
		print("Which set of data? Enter 1-5", terminator: "")
	}, isValid: {input in
		return 1...5 ~= (Int(input) ?? -1)
	}, action: {datasetString in
		set = Int(datasetString)!
		
		return .next
	}), Menu(printMenu: {
		print("Preform prediction of labels for classification of set \(set)?")
		print("Type y/n", terminator: "")
	}, isValid: {choice in
		return choice == "y" || choice == "n"
	}, action: {choice in
		if choice == "n" {
			return .last
		}
		
		if FileManager.default.fileExists(atPath: "FerreiraClassification\(set).txt") {
			let override = prompt(Menu(printMenu: {
				print("The test labels have already been generated for this set...")
				print("Override? Enter y/n", terminator: "")
			}, isValid: {input in
				return input == "y" || input == "n"
			}, action: {choice in
				switch choice {
				case "y":
					return .next
				default:
					return .last
				}
			}))
			
			if override == .same {
				return .last
			}
		}
		
		let result = runRscript("problem-two-set-n.r", "\(set)")
		
		if result != .next {
			return .last
		}
		
		do {
			return try finishUpSet(set)
		} catch {
			return .last
		}
	}), loop: true)
}

private func finishUpSet(_ set: Int) throws -> Next {
	guard let prediction = readFrom("FerreiraClassification\(set).txt") else {
		print("Set file not found! Are you in the right directory? Did you run the R script?")
		print()
		
		throw "File Not Found"
	}
	
	let results = prediction
		.split(separator: "\n")
		.dropFirst()
		.map { $0.split(separator: " ").filter { $0 != "" }[1] }
		.joined(separator: "\n")
	
	do {
		try results.write(toFile: "FerreiraClassification\(set).txt", atomically: false, encoding: .utf8)
	} catch {
		print("Error writing back to file: ", error)
		exit(-1)
	}
	
	print("Successfully written predicted labels to \"FerreiraClassification\(set).txt\"")
	print()
	
	return .next
}
