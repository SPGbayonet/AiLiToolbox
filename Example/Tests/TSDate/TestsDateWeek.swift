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

            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"

            let today = formatter.date(from: "2017-06-08 17:48:05")!
            let yesterday = today.addingTimeInterval(TimeInterval(-24 * 60 * 60))
            let toyesterday = yesterday.addingTimeInterval(TimeInterval(-24 * 60 * 60))
            let otherday = toyesterday.addingTimeInterval(TimeInterval(-24 * 60 * 60))

            let weekday = formatter.date(from: "2017-05-09 10:04:30")!

            let oneString = TSDate().weekdateString(.wallet, json: today, user: today)//同年同月同日
            let twoString = TSDate().weekdateString(.wallet, json: yesterday, user: today)//同年同月少一日
            let threeString = TSDate().weekdateString(.wallet, json: toyesterday, user: today)//同年同月少二日
            let fourString = TSDate().weekdateString(.wallet, json: otherday, user: today)//同年同月少三日，走brek

            let fiveString = TSDate().weekdateString(.wallet, json: weekday, user: today)//同年不月，直接return

            let sixString = TSDate().weekdateString(.walletdetail, json: weekday, user: today)//转换带有星期几的字符串

            //测试方法中default情况
            let datestringV = TSDate().dateString(.wallet, nsDate: today as NSDate)
            let weekstringV = TSDate().weekdateString(.detail, json: today, user: today)
            it("进行输出比较") {
                let today = "今天\n06.08"
                let yesterday = "昨天\n06.07"
                let nineDayAnswer = "前天\n06.06"
                let nineDayMoreAnswer = "Monday\n06.05"
                let moredaystring = "Tuesday\n05.09"

                let weekdaystring = "2017-05-09 Tuesday 10:04"

                let dateV = ""
                let weekV = ""

                expect(oneString) == today
                expect(twoString) == yesterday
                expect(threeString) == nineDayAnswer
                expect(fourString) == nineDayMoreAnswer
                expect(fiveString) == moredaystring

                expect(sixString) == weekdaystring

                expect(datestringV) == dateV
                expect(weekstringV) == weekV
            }
        }
    }
}
