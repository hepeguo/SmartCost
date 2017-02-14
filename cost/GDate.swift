//
//  GDate.swift
//
//  Created by bujiandi(慧趣小歪) on 14/9/26.
//
//  值类型的 GDate 使用方便 而且避免使用 @NSCopying 的麻烦
//  基本遵循了官方所有关于值类型的实用协议 放心使用
//

import Foundation

func ===(lhs: GDate, rhs: GDate) -> Bool {
    return lhs.timeInterval == rhs.timeInterval
}
func ==(lhs: GDate, rhs: GDate) -> Bool {
    let l = lhs.getDay()
    let r = rhs.getDay()
    return l.year == r.year && l.month == r.month && l.day == r.day
}
func !=(lhs: GDate, rhs: GDate) -> Bool {
    let l = lhs.getDay()
    let r = rhs.getDay()
    return l.year != r.year || l.month != r.month || l.day != r.day
}
func <=(lhs: GDate, rhs: GDate) -> Bool {
    return lhs.timeInterval <= rhs.timeInterval
}
func >=(lhs: GDate, rhs: GDate) -> Bool {
    return lhs.timeInterval >= rhs.timeInterval
}
func >(lhs: GDate, rhs: GDate) -> Bool {
    return lhs.timeInterval > rhs.timeInterval
}
func <(lhs: GDate, rhs: GDate) -> Bool {
    return lhs.timeInterval < rhs.timeInterval
}
func +(lhs: GDate, rhs: TimeInterval) -> GDate {
    return GDate(rhs, sinceDate:lhs)
}
func -(lhs: GDate, rhs: TimeInterval) -> GDate {
    return GDate(-rhs, sinceDate:lhs)
}
func +(lhs: TimeInterval, rhs: GDate) -> GDate {
    return GDate(lhs, sinceDate:rhs)
}
func -(lhs: TimeInterval, rhs: GDate) -> GDate {
    return GDate(-lhs, sinceDate:rhs)
}

func +=(lhs: inout GDate, rhs: TimeInterval) {
    return lhs = GDate(rhs, sinceDate:lhs)
}
func -=(lhs: inout GDate, rhs: TimeInterval) {
    return lhs = GDate(-rhs, sinceDate:lhs)
}


struct GDate {
    var timeInterval:TimeInterval = 0
    
    init() { self.timeInterval = Date().timeIntervalSince1970 }
}

// MARK: - 输出
extension GDate {
    func stringWithFormat(_ format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: timeInterval))
    }
}

// MARK: - 计算
extension GDate {
    mutating func addDay(_ day:Int) -> GDate {
        let second = timeInterval + Double(day) * 24 * 3600
        return GDate(second)
    }
    mutating func addHour(_ hour:Int) {
        timeInterval += Double(hour) * 3600
    }
    mutating func addMinute(_ minute:Int) {
        timeInterval += Double(minute) * 60
    }
    mutating func addSecond(_ second:Int) {
        timeInterval += Double(second)
    }
    mutating func addMonth(month m:Int) {
        let (year, month, day) = getDay()
        let (hour, minute, second) = getTime()
        let era = year / 100
        if let date = (Calendar.current as NSCalendar).date(era: era, year: year, month: month + m, day: day, hour: hour, minute: minute, second: second, nanosecond: 0) {
            timeInterval = date.timeIntervalSince1970
        } else {
            timeInterval += Double(m) * 30 * 24 * 3600
        }
    }
    mutating func addYear(year y:Int) {
        let (year, month, day) = getDay()
        let (hour, minute, second) = getTime()
        let era = year / 100
        if let date = (Calendar.current as NSCalendar).date(era: era, year: year + y, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: 0) {
            timeInterval = date.timeIntervalSince1970
        } else {
            timeInterval += Double(y) * 365 * 24 * 3600
        }
    }
}

// MARK: - 判断
extension GDate {
    func between(_ begin:GDate,_ over:GDate) -> Bool {
        return (self >= begin && self <= over) || (self >= over && self <= begin)
    }
}

// MARK: - 获取 日期 或 时间
extension GDate {
    
    // for example : let (year, month, day) = date.getDay()
    func getDay() -> (year:Int, month:Int, day:Int) {
        var year:Int = 0, month:Int = 0, day:Int = 0
        let date = Date(timeIntervalSince1970: timeInterval)
        (Calendar.current as NSCalendar).getEra(nil, year: &year, month: &month, day: &day, from: date)
        return (year, month, day)
    }
    
    // for example : let (hour, minute, second) = date.getTime()
    func getTime() -> (hour:Int, minute:Int, second:Int) {
        var hour:Int = 0, minute:Int = 0, second:Int = 0
        let date = Date(timeIntervalSince1970: timeInterval)
        (Calendar.current as NSCalendar).getHour(&hour, minute: &minute, second: &second, nanosecond: nil, from: date)
        return (hour, minute, second)
    }
    
    func getWeek() -> (year: Int, dayOfWeek: Int, weekOfYear: Int) {
        var dayOfWeek:Int = 0, weekOfYear:Int = 0, year: Int = 0
        let date = Date(timeIntervalSince1970: timeInterval)
        (Calendar.current as NSCalendar).getEra(nil,yearForWeekOfYear: &year, weekOfYear: &weekOfYear, weekday: &dayOfWeek, from: date)
        return (year, dayOfWeek, weekOfYear)
    }
}

// MARK: - 构造函数
extension GDate {
    init(year:Int, month:Int = 1, day:Int = 1, hour:Int = 0, minute:Int = 0, second:Int = 0) {
        let era = year / 100
        if let date = (Calendar.current as NSCalendar).date(era: era, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: 0) {
            timeInterval = date.timeIntervalSince1970
        }
    }
}

extension GDate {
    init(_ v: TimeInterval) { timeInterval = v }
    
    init(_ v: TimeInterval, sinceDate:GDate) {
        let date = Date(timeIntervalSince1970: sinceDate.timeInterval)
        timeInterval = Date(timeInterval: v, since: date).timeIntervalSince1970
    }
    
    init(sinceNow: TimeInterval) {
        timeInterval = Date(timeIntervalSinceNow: sinceNow).timeIntervalSince1970
    }
    
    init(sinceReferenceDate: TimeInterval) {
        timeInterval = Date(timeIntervalSinceReferenceDate: sinceReferenceDate).timeIntervalSince1970
    }
}

extension GDate {
    init(_ v: String, style: DateFormatter.Style = .none) {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        if let date = formatter.date(from: v) {
            self.timeInterval = date.timeIntervalSince1970
        }
    }
    
    init(_ v: String, dateFormat:String = "yyyy-MM-dd HH:mm:ss") {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let date = formatter.date(from: v) {
            self.timeInterval = date.timeIntervalSince1970
        }
    }
}

extension GDate {
    init(_ v: UInt8) { timeInterval = Double(v) }
    init(_ v: Int8) { timeInterval = Double(v) }
    init(_ v: UInt16) { timeInterval = Double(v) }
    init(_ v: Int16) { timeInterval = Double(v) }
    init(_ v: UInt32) { timeInterval = Double(v) }
    init(_ v: Int32) { timeInterval = Double(v) }
    init(_ v: UInt64) { timeInterval = Double(v) }
    init(_ v: Int64) { timeInterval = Double(v) }
    init(_ v: UInt) { timeInterval = Double(v) }
    init(_ v: Int) { timeInterval = Double(v) }
}

extension GDate {
    init(_ v: Float) { timeInterval = Double(v) }
    //init(_ v: Float80) { timeInterval = Double(v) }
}

// MARK: - 可以直接输出
extension GDate : CustomStringConvertible {
    var description: String {
        return Date(timeIntervalSince1970: timeInterval).description
    }
}
extension GDate : CustomDebugStringConvertible {
    var debugDescription: String {
        return Date(timeIntervalSince1970: timeInterval).debugDescription
    }
}
//
//// MARK: - 可以直接赋值整数
//extension Date : IntegerLiteralConvertible {
//    static func convertFromIntegerLiteral(value: Int64) -> Date {
//        return Date(Double(value))
//    }
//}
//
//// MARK: - 可以直接赋值浮点数
//extension Date : FloatLiteralConvertible {
//    static func convertFromFloatLiteral(value: Double) -> Date {
//        return Date(value)
//    }
//}

// MARK: - 可反射
//extension GDate : Reflectable {
//    func getMirror() -> MirrorType {
//        return reflect(self)
//    }
//}

// MARK: - 可哈希
extension GDate : Hashable {
    var hashValue: Int { return timeInterval.hashValue }
}

// 可以用 == 或 != 对比
extension GDate : Equatable {
    
}

// MARK: - 可以用 > < >= <= 对比
extension GDate : Comparable {
    
}
