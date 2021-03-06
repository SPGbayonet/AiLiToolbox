//
//  RquestNetworkData.swift
//  Pods
//
//  Created by lip on 2017/5/16.
//
//  网络请求数据处理

import UIKit
import Alamofire

public enum RquestNetworkDataError: Error {
    /// 未正常初始化
    case uninitialized
}

/// 服务器响应数据
///
/// 服务器可能会响应 Dictionary<String, Any>; Array<Any>; 以及 空数组
/// 服务器指定使用空数组表示无数据的情况
/// - Warning: 当出现数据解析或者超时等错误时, 返回 nil
public typealias NetworkResponse = Any?

public let kRequestNetworkDataErrorDomain = "com.zhiyicx.ios.error.network"

public class RequestNetworkData: NSObject {
    private var rootURL: String?
    private let textRequestTimeoutInterval = 10
    private var authorization: String?
    private override init() {}

    public static let share = RequestNetworkData()
    /// 配置是否显示日志信息,默认是关闭的
    ///
    /// - Note: 开启后,每次网络请求都会在控制台打印请求数据和请求结果
    public var isShowLog = false

    lazy var alamofireManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.textRequestTimeoutInterval)
        return Alamofire.SessionManager(configuration: configuration)
    }()

    // MARK: - config
    /// 设置请求的根地址
    ///
    /// - Parameter rootURL: 根地址字符串
    /// - Note: 设置后会导致所有的请求都依照该地址发起
    public func configRootURL(rootURL: String?) {
        self.rootURL = rootURL
    }

    /// 配置请求的授权口令
    ///
    /// - Note: 配置后,每次请求的都会携带该参数
    public func configAuthorization(_ authorization: String?) {
        self.authorization = authorization
    }

    /// 和服务器间的文本请求
    ///
    /// - Parameters:
    ///   - method: 请求方式
    ///   - path: 请求路径,拼接在根路径后
    ///   - parameter: 请求参数
    ///   - complete: 请求结果
    /// - Note: 当服务响应错误时,返回值 NetworkResponse 为空,具体错误信息控制台会打印
    /// - Throws: 错误状态,如果未成功配置根地址会抛错
    public func textRequest(method: HTTPMethod, path: String?, parameter: Dictionary<String, Any>?, complete: @escaping (_ responseData: NetworkResponse, _ responseStatus: Bool) -> Void) throws {

        let (coustomHeaders, requestPath) = try processParameters(self.authorization, path)

        if self.isShowLog == true {
            let authorization: String = self.authorization ?? "nil"
            print("\nRootURL:\(requestPath)\nAuthorization:" + (authorization) + "\nRequestMethod:\(method)\nParameters:\n\(parameter)\n")
        }

        alamofireManager.request(requestPath, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: coustomHeaders).responseJSON { [unowned self] response in
            if self.isShowLog == true {
                print("http respond info \(response)")
            }
            if let error = response.result.error {
                print("http respond error \(error)")
            }
            var responseStatus: Bool = false
            if let response = response.response {
                if response.statusCode >= 200 && response.statusCode < 300 {
                    responseStatus = true
                }
            }
            complete(response.result.value, responseStatus)
        }
    }

    private func processParameters(_ authorization: String?, _ path: String?) throws -> (HTTPHeaders?, String) {
        guard let rootURL = self.rootURL else {
            throw RquestNetworkDataError.uninitialized
        }

        var coustomHeaders: HTTPHeaders = ["Accept": "application/json"]
        if let authorization = authorization {
            let token = "Bearer " + authorization
            coustomHeaders.updateValue(token, forKey: "Authorization")
        }

        var requestPath: String = ""
        if let path = path {
            requestPath = rootURL + path
        } else {
            requestPath = rootURL
        }
        return (coustomHeaders, requestPath)
    }
}
