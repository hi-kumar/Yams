//
//  MarkTests.swift
//  Yams
//
//  Created by Norio Nomura on 4/11/17.
//  Copyright (c) 2017 Yams. All rights reserved.
//

import XCTest
import Yams

class MarkTests: XCTestCase {
    func testLocatableDeprecationMessageForSwiftLint() throws {
        let deprecatedRulesIdentifiers = [("variable_name", "identifier_name")].map { (Node($0.0), $0.1) }
        func deprecatedMessage(from rule: Node) -> String? {
            guard let index = deprecatedRulesIdentifiers.index(where: { $0.0 == rule }) else {
                return nil
            }
            let changed = deprecatedRulesIdentifiers[index].1
            return "\(rule.mark?.description ?? ""): warning: '\(rule.string ?? "")' has been renamed to " +
                "'\(changed)' and will be completely removed in a future release."
        }

        let yaml = [
            "disabled_rules:",
            "  - variable_name",
            "  - line_length",
            "variable_name:",
            "  min_length: 2"
            ].joined(separator: "\n")
        let configuration = try Yams.compose(yaml: yaml)
        let disabled_rules = configuration?.mapping?["disabled_rules"]?.array() ?? []
        let configured_rules = configuration?.mapping?.keys.filter({ $0 != "disabled_rules" }) ?? []
        let deprecatedMessages = (disabled_rules + configured_rules).flatMap(deprecatedMessage(from:))
        XCTAssertEqual(deprecatedMessages, [
            "2:5: warning: 'variable_name' has been renamed to " +
                "'identifier_name' and will be completely removed in a future release.",
            "4:1: warning: 'variable_name' has been renamed to " +
                "'identifier_name' and will be completely removed in a future release."
            ])
    }
}

extension MarkTests {
    static var allTests: [(String, (MarkTests) -> () throws -> Void)] {
        return [
            ("testLocatableDeprecationMessageForSwiftLint", testLocatableDeprecationMessageForSwiftLint)
        ]
    }
}
