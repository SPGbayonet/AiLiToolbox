//
//  TSDataBaseManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  数据库管理类

/// 时间类型
public enum DateType {
    /// - simple: 个人主页
    /// - 1天内显示 今\n天，
    /// - 1天到2天显示 昨\n天，
    /// - 2天以上显示月日如 24\n12月、09\n2 月，当月份小于 10 时，数字和月份之间有个空格
    case simple
    /// normal: 动态列表时间戳格式转换
    /// - 一分钟内显示一分钟
    /// - 一小时内显示几分钟前
    /// - 一天内显示几小时前
    /// - 1天到2天显示昨天
    /// - 2天到9天显示几天前
    /// - 9天以上显示月日如（05-21）
    case normal
    /// 动态详情
    /// - 一分钟内显示一分钟
    /// - 一小时内显示几分钟前，
    /// - 一天内显示几小时前，
    /// - 1天到2天显示如（昨天 20:36），
    /// - 2天到9天显示如（五天前 20：34），
    /// - 9天以上显示如（02-28 19:15）
    case detail
    /// 明细（钱包）
    /// - eg:2017-06-07 16:07:27
    /// - 今天内显示     今天\n06.07
    /// - -1天内显示     昨天\n06.07
    /// - -2天内显示     前天\n06.07
    /// - 其他时间显示    星期三\n06.07
    case wallet
    /// 明细详情（钱包）
    /// - 2017-06-07 16:00 转换成 2017-06-07 星期三 16:00
    case walletdetail
}

public class TSDate: NSObject {

    // MARK: - Lifecycle
    /// 日程表
    private let calendar = Calendar(identifier: .gregorian)
    /// 当前时间
    private var now: Date
    /// 当天零点
    private var today = Date()
    /// 昨天零点
    private var yesterday = Date()
    /// 9 天前
    private var nightday = Date()
    /// 一分钟前
    private var oneMinute = Date()
    /// 一小时前
    private var oneHour = Date()
    /// 格式转换器
    private let formatter = DateFormatter()

    /// 后台返回时间
    private var date = Date()

    // MARK: - Lifecycle
    public override convenience init() {
        self.init(now: Date())
    }

    /// 用于测试的初始化方法
    ///
    /// - Parameter now: 作为“现在”标准的时间
    public init(now: Date) {
        self.now = now
        today = calendar.startOfDay(for: now)
        yesterday = calendar.date(byAdding: Calendar.Component.day, value: -1, to: today, wrappingComponents: false)!
        nightday = calendar.date(byAdding: Calendar.Component.day, value: -9, to: today, wrappingComponents: false)!
        oneMinute = calendar.date(byAdding: Calendar.Component.minute, value: -1, to: now, wrappingComponents: false)!
        oneHour = calendar.date(byAdding: Calendar.Component.hour, value: -1, to: now, wrappingComponents: false)!
    }

    // MARK: - Public

    /// 转换成时间
    ///
    /// - Parameters:
    ///   - type: 转换类型
    ///   - timeStamp: 时间戳
    /// - Returns: 计算后的字符串
    public func dateString(_ type: DateType, nsDate: NSDate) -> String {
        date = convertToDate(nsDate)
        var dateString = ""
        switch type {
        case .simple:
            dateString = simpleDate()
        case .normal:
            dateString = normalDate()
        case .detail:
            dateString = detailDate()
        default:
            break
        }
        return dateString
    }

        public func weekdateString(_ type: DateType, json: Date, user: Date) -> String {
        var dateString = ""
        switch type {
        case .wallet:
            dateString = comparingToday(json, user: user)
        case .walletdetail:
            dateString = convertToWeekday(json)
        default:
            break
        }
        return dateString
    }

    /// 转换成时间
    ///
    /// - Parameters:
    ///   - type: 转换类型
    ///   - timeStamp: 时间戳
    /// - Returns: 计算后的字符串
    //    func dateString(_ type: DateType, time: NSDate) -> String {
    //        let timeStampInt = Int(time.timeIntervalSince1970)
    //        return dateString(type, timeStamp: timeStampInt)
    //    }

    // MARK: - Private

    /// simple 类型的时间
    /// - Note:
    /// 个人主页
    /// 1天内显示 今\n天，
    /// 1天到2天显示 昨\n天，
    /// 2天以上显示月日如 24\n12月、09\n2 月，当月份小于 10 时，数字和月份之间有个空格
    ///
    private func simpleDate() -> String {
        if isLate(than: today) {
            return "今\n天"
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "昨\n天"
        }
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: date))!
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        if month < 10 {
            return day + "\n\(month) 月"
        }
        return day + "\n\(month)月"
    }

    /// normal 类型的时间
    ///
    /// - Note:
    /// 动态列表时间戳格式转换
    /// 一分钟内显示一分钟内
    /// 一小时内显示几分钟前
    /// 一天内显示几小时前
    /// 1天到2天显示昨天
    /// 2天到9天显示几天前
    /// 9天以上显示月日如（05-21）
    private func normalDate() -> String {
        let comphoent = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        if isLate(than: oneMinute) {
            return "1分钟内"
        }
        if isLate(than: oneHour) && isEarly(than: oneMinute) {
            return "\((comphoent.minute)!)分钟前"
        }
        if isLate(than: today) && isEarly(than: oneHour) {
            return "\((comphoent.hour)!)小时前"
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "昨天"
        }
        if isLate(than: nightday) && isEarly(than: yesterday) {
            return "\(comphoent.day! - 1)天前"
        }
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }

    /// detail 类型的时间
    ///
    /// - Note:
    /// 一分钟内显示一分钟内
    /// 一小时内显示几分钟前，
    /// 一天内显示几小时前，
    /// 1天到2天显示如（昨天 20:36），
    /// 2天到9天显示如（五天前 20：34），
    /// 9天以上显示如（02-28 19:15）
    private func detailDate() -> String {
        let comphoent = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        if isLate(than: oneMinute) {
            return "1分钟内"
        }
        if isLate(than: oneHour) && isEarly(than: oneMinute) {
            return "\((comphoent.minute)!)分钟前"
        }
        if isLate(than: today) && isEarly(than: oneHour) {
            return "\((comphoent.hour)!)小时前"
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            formatter.dateFormat = "HH:mm"
            return "昨天 \(formatter.string(from: date))"
        }
        if isLate(than: nightday) && isEarly(than: yesterday) {
            formatter.dateFormat = "HH:mm"
            return "\(comphoent.day! - 1)天前 \(formatter.string(from: date))"
        }
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }

    /// 是否早于某个时间
    private func isEarly(than compareDate: Date) -> Bool {
        return date < compareDate
    }

    /// 是否晚于某个时间
    private func isLate(than compareDate: Date) -> Bool {
        return date >= compareDate
    }

    /// 将 NSDate 转换成 Date
    private func convertToDate(_ nsDate: NSDate) -> Date {
        return Date(timeIntervalSince1970: nsDate.timeIntervalSince1970)
    }
    /// 根据 Date 转换成带星期几的字符串
    private func convertToWeekday(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd eeee HH:mm"
        let string = dateFormatter.string(for: date)!
        return string
    }

    /// 根据 Date 返回 周几+月日
    private func comparingToday(_ json: Date, user: Date) -> String {

        let getjson = json//拿到后台数据
        let getuser = user//拿到对比数据
        let deFormatter = DateFormatter()
        deFormatter.dateFormat = "EEEE\nMM.dd"// 转换格式

        let calendar = Calendar.current//拆分date，年/月/日
        let todaycompes = calendar.dateComponents([.year, .month, .day], from: getuser)
        let getdaycompes = calendar.dateComponents([.year, .month, .day], from: getjson)

        let  Dvalue = getdaycompes.day! - todaycompes.day!
        // 年月日相同时进行比较输出
        if (todaycompes.year == getdaycompes.year) && (todaycompes.month == getdaycompes.month) {
            switch Dvalue {
            case 0:
                // 今天
                deFormatter.dateFormat = "MM.dd"
                return "今天\n\(deFormatter.string(from: getjson))"
            case -1:
                // 昨天
                deFormatter.dateFormat = "MM.dd"
                return "昨天\n\(deFormatter.string(from: getjson))"
            case -2:
                // 前天
                deFormatter.dateFormat = "MM.dd"
                return "前天\n\(deFormatter.string(from: getjson))"
            default:
                // 超过前天的跳过出去直接输出
                break
            }
        }
        return deFormatter.string(from: getjson)
    }
}
