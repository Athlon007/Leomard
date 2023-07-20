//
//  TagNameVersionTests.swift
//  LeomardTests
//
//  Created by Konrad Figura on 20/07/2023.
//

import XCTest
@testable import Leomard

final class TagNameVersionTests: XCTestCase {
    
    func testVersion110IsNewerThan100() throws {
        let versionA = TagNameVersion(major: 1, minor: 1, build: 0)
        let versionB = TagNameVersion(major: 1, minor: 0, build: 0)
        
        XCTAssertGreaterThan(versionA, versionB)
    }
    
    func testVersion111IsNewerThan110() throws {
        let versionA = TagNameVersion(major: 1, minor: 1, build: 1)
        let versionB = TagNameVersion(major: 1, minor: 1, build: 0)
        
        XCTAssertGreaterThan(versionA, versionB)
    }
    
    func testVersion120IsNewerThan111() throws {
        let versionA = TagNameVersion(major: 1, minor: 2, build: 0)
        let versionB = TagNameVersion(major: 1, minor: 1, build: 1)
        
        XCTAssertGreaterThan(versionA, versionB)
    }
    
    func testVersion200IsNewerThan111() throws {
        let versionA = TagNameVersion(major: 2, minor: 0, build: 0)
        let versionB = TagNameVersion(major: 1, minor: 1, build: 1)
        
        XCTAssertGreaterThan(versionA, versionB)
    }
    
    func testVersion100IsEqual100() throws {
        let versionA = TagNameVersion(major: 1, minor: 0, build: 0)
        let versionB = TagNameVersion(major: 1, minor: 0, build: 0)
    
        XCTAssertEqual(versionA, versionB)
    }
    
    func testVersion100IsNotNewerThan110() throws {
        let versionA = TagNameVersion(major: 1, minor: 0, build: 0)
        let versionB = TagNameVersion(major: 1, minor: 1, build: 0)
        
        XCTAssertLessThan(versionA, versionB)
    }
    
    func testDecoding100FromStringEquals100() throws {
        let versionA = try TagNameVersion(textVersion: "1.0")
        let versionB = TagNameVersion(major: 1, minor: 0, build: 0)
        
        XCTAssertEqual(versionA, versionB)
    }
    
    func testDecodingInvalidTextThrowsVersionFromStringDecodeErrorError() {
        XCTAssertThrowsError(try TagNameVersion(textVersion: "invalid"))
    }
}
