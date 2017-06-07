//
//  TestsDateWeek.swift
//  AiLiToolbox
//
//  Created by Fiction on 2017/6/7.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//

import Quick
import Nimble
import AiLiToolbox

class TestsDateWeek: TestsDate {

    override func spec() {
        resetTimes()
        describe("传入一天之内的时间") {

            let oneString = TSDate(now: egday).dateString(.wallet, nsDate: today as NSDate)
            let twoString = TSDate(now: egday).dateString(.wallet, nsDate: Yesterday as NSDate)
            let threeString = TSDate(now: egday).dateString(.wallet, nsDate: toyesterday as NSDate)
            let fourString = TSDate(now: egday).dateString(.wallet, nsDate: otherday as NSDate)
            let fiveString = TSDate(now: egday).dateString(.walletdetail, nsDate: egday as NSDate)
            it("将时间戳转换成显示字符串") {
                let today = "今天\n06.07"
                let yesterday = "昨天\n06.06"
                let nineDayAnswer = "前天\n06.05"
                let nineDayMoreAnswer = "Tuesday\n05.09"
                let moredaystring = "2017-06-07 Wednesday 16:44"
                expect(oneString) == today
                expect(twoString) == yesterday
                expect(threeString) == nineDayAnswer
                expect(fourString) == nineDayMoreAnswer
                expect(fiveString) == moredaystring
            }
        }
    }
}
