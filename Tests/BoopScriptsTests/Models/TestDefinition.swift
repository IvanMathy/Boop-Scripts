//
//  File.swift
//  
//
//  Created by Ivan on 10/27/21.
//

import Foundation

class TestDefinition: Codable {
    let name: String
    let input: InputDefinition
    let output: OutputDefinition
}

class InputDefinition: Codable {
    let fullText: String
}

class OutputDefinition: Codable {
    let fullText: String
}
