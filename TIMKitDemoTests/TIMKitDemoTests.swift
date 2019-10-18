//
//  TIMKitDemoTests.swift
//  TIMKitDemoTests
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import XCTest
@testable import TIMKitDemo

class TIMKitDemoTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let n1 = round(2.0)
        let n2 = ceil(2.0)
        let n3 = floor(3.4)
        print(n1, n2, n3)
        let data = "{}".data(using: .utf8)
        if let voiceContent = VoiceMessageContent(data: data!) {
            let json = voiceContent.jsonString()
            Log.i("转换c成功", voiceContent, json)
        } else {
            Log.e("转换失败")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
