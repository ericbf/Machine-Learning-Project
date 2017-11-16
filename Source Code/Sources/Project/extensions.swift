//
//  shuffle.swift
//  Project
//
//  Created by Eric Ferreira on 11/12/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation

extension MutableCollection {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let max: Int = numericCast(unshuffledCount)
			
			#if os(Linux)
				let rand = Int(random() % max)
			#else
				let rand = Int(arc4random_uniform(UInt32(max)))
			#endif
			
			let d: IndexDistance = numericCast(rand)
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
}

extension Sequence {
	/// Returns an array with the contents of this sequence, shuffled.
	func shuffled() -> [Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}

extension Collection {
	/// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension String: Error {}
