//
//  problem-one.swift
//  Project
//
//  Created by Eric Ferreira on 11/15/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation

func problemOne() -> Next {
	var dataset = -1
	
	return prompt(Menu(printMenu: {
		print("Which dataset? Enter 1-3", terminator: "")
	}, isValid: {input in
		return 1...3 ~= (Int(input) ?? -1)
	}, action: {datasetString in
		dataset = Int(datasetString)!
		
		return prompt(Menu(printMenu: {
			print("What do you want to do?")
			print("\t1. Test training data of dataset \(dataset) using 5-fold technique")
			print("\t2. Predict values for the unknowns of dataset \(dataset)")
			print("Enter 1-2", terminator: "")
		}, isValid: {input in
			return 1...2 ~= (Int(input) ?? -1)
		}, action: {choice in
			do {
				switch choice {
				case "1":
					try explode(dataset)
					
					if runRscript("problem-one-test-n.r", "\(dataset)") == .last {
						return .same
					}
				case "2":
					let finishUp = try predict(dataset)
					
					if runRscript("problem-one-predict-n.r", "\(dataset)") == .last {
						return .same
					}
					
					try finishUp()
				default:
					break
				}
			} catch {
				return .same
			}
			
			return .next
		}), loop: true)
	}))
}

private func explode(_ dataset: Int) throws {
	let inputFile = "Dataset \(dataset).txt" //read()
	
	guard let inputString = readFrom(inputFile) else {
		print("Dataset not found! Are you in the right directory?")
		print()
		
		throw "File not found"
	}
	
	let input = inputString.split(separator: "\n").map {row in
		return row.split(separator: "\t").map {item in
			return Decimal(string: String(item))
		}.map {item in
			return Decimal(string: "1e+99") == item ? nil : item
		}
	}.enumerated().flatMap {y, row in
		return row.enumerated().map {x, item in
			return (x: x, y: y, z: item)
		}
	}
	
	func printValues(_ values: [(x: Int, y: Int, z: Decimal?)], to file: String) {
		try? values.reduce("") {partial, next in
			var partial = partial
			
			if partial != "" {
				partial += "\n"
			}
			
			if let z = next.z {
				return "\(partial)\(next.x)\t\(next.y)\t\(z)"
			} else {
				return "\(partial)\(next.x)\t\(next.y)"
			}
		}.write(toFile: "\(file)", atomically: false, encoding: .utf8)
	}
	
	let values = input.filter { return $0.z != nil }.shuffled()
	
	func excludeNthFifth(_ n: Int, from data: [(x: Int, y: Int, z: Decimal?)]) {
		let fifth = data.count / 5
		
		let start = n == 1 ? fifth : 0
		let end = n == 1 ? data.count : fifth * (n - 1)
		
		var included = data[start..<end]
		
		if n != 1 && n != 5 {
			included += data[(end + fifth)..<data.count]
		}
		
		let excluded = n == 1 ? data[0..<fifth] : data[end..<(end + fifth)]
		
		printValues(Array(included), to: "Dataset \(dataset) included \(n).txt")
		printValues(Array(excluded), to: "Dataset \(dataset) excluded \(n).txt")
	}
	
	for i in 1...5 {
		excludeNthFifth(i, from: values)
	}
	
	print("Successfully exploded the dataset into five 5-fold training sets, excluding unknowns")
	print()
}

func splitMatrix(_ input: String) -> (matrix: [[Decimal?]], knowns: [(x: Int, y: Int, z: Decimal?)], unknowns: [(x: Int, y: Int, z: Decimal?)]) {
	let matrix = input.split(separator: "\n").map {row in
		return row.split(separator: "\t").map {item in
			return Decimal(string: String(item))
			}.map {item in
				return Decimal(string: "1e+99") == item ? nil : item
		}
	}
	
	let input = matrix.enumerated().flatMap {y, row in
		return row.enumerated().map {x, item in
			return (x: x, y: y, z: item)
		}
	}
	
	let knowns = input.filter { return $0.z != nil }
	let unknowns = input.filter { return $0.z == nil }
	
	return (matrix, knowns, unknowns)
}

private func predict(_ dataset: Int) throws -> () throws -> Void {
	let inputFile = "Dataset \(dataset).txt"
	
	guard let inputString = readFrom(inputFile) else {
		print("Dataset not found! Did you run the r script?")
		print()
		
		throw "File not found"
	}
	
	var (matrix, knowns, unknowns) = splitMatrix(inputString)
	
	printValues(knowns, to: "Dataset \(dataset) knowns.txt")
	printValues(unknowns, to: "Dataset \(dataset) unknowns.txt")
	
	print("Successfully separated knowns and unknowns of dataset \(dataset)")
	print()
	
	func finishPrediction() throws {
		guard let resultsString = readFrom("FerreiraMissingResult\(dataset).txt") else {
			print("Dataset not found! Are you in the right directory? Did you run the R script?")
			print()
			
			throw "File not found"
		}
		
		let results = resultsString
			.split(separator: "\n")
			.dropFirst()
			.map {$0.split(separator: " ").filter {String($0) != ""}[1]}
			.map {Decimal(string: String($0))}
		
		let predicted = unknowns.enumerated().map {i, item in
			return (x: item.x, y: item.y, z: results[i])
		}
		
		for item in predicted {
			matrix[item.y][item.x] = item.z
		}
		
		var output = ""
		
		for (row, items) in matrix.enumerated() {
			for (column, item) in items.enumerated() {
				output += "\(item!)"
				
				if column < items.count - 1 {
					output += "\t"
				}
			}
			
			if row < matrix.count - 1 {
				output += "\n"
			}
		}
		
		try output.write(toFile: "FerreiraMissingResult\(dataset).txt", atomically: false, encoding: .utf8)
		
		print("Successfully printed out estimation to \"FerreiraMissingResult\(dataset).txt\"")
		print()
	}
	
	return finishPrediction
}

private func printValues(_ values: [(x: Int, y: Int, z: Decimal?)], to file: String) {
	try? values.reduce("") {partial, next in
		var partial = partial
		
		if partial != "" {
			partial += "\n"
		}
		
		if let z = next.z {
			return "\(partial)\(next.x)\t\(next.y)\t\(z)"
		} else {
			return "\(partial)\(next.x)\t\(next.y)"
		}
	}.write(toFile: "\(file)", atomically: false, encoding: .utf8)
}
