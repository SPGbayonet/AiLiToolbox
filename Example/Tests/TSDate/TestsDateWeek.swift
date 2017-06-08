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
        describe("传入五个不同的值") {

            let oneString = TSDate().dateString(.wallet, nsDate: today as NSDate)//同年同月同日
            let twoString = TSDate().dateString(.wallet, nsDate: Yesterday as NSDate)//同年同月少一日
            let threeString = TSDate().dateString(.wallet, nsDate: toyesterday as NSDate)//同年同月少二日
            let fourString = TSDate().dateString(.wallet, nsDate: otherday as NSDate)//同年同月少三日，走brek
            let fiveString = TSDate().dateString(.wallet, nsDate: weekday as NSDate)//同年不月，直接return

            let sixString = TSDate().dateString(.walletdetail, nsDate: weekday as NSDate)
            it("进行输出比较") {
                let today = "今天\n06.08"
                let yesterday = "昨天\n06.07"
                let nineDayAnswer = "前天\n06.06"
                let nineDayMoreAnswer = "Monday\n06.05"
                let moredaystring = "Tuesday\n05.09"

                let weekdaystring = "2017-05-09 Tuesday 10:04"
                expect(oneString) == today
                expect(twoString) == yesterday
                expect(threeString) == nineDayAnswer
                expect(fourString) == nineDayMoreAnswer
                expect(fiveString) == moredaystring

                expect(sixString) == weekdaystring
            }
        }
    }
}
