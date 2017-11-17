//
//  problem-three.swift
//  Project
//
//  Created by Eric Ferreira on 11/15/17.
//  Copyright © 2017 Eric Ferreira. All rights reserved.
//

import Foundation

func problemThree() -> Next {
	return prompt(Menu(printMenu: {
		print("Preform prediction of labels for multi-label classification?")
		print("Type y/n", terminator: "")
	}, isValid: {choice in
		return choice == "y" || choice == "n"
	}, action: {choice in
		if choice == "n" {
			return .last
		}
		
		let result = runRscript("problem-three-predict.r")
		
		if result == .next {
			print("Succesfully wrote classification to \"FerreiraMultLabelClassification1.txt\"")
			print()
		}
		
		return result
	}))
}
