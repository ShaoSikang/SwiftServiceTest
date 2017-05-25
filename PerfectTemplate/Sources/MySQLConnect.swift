//
//  MySQLConnect.swift
//  PerfectTemplate
//
//  Created by Sikang Shao on 2017/5/5.
//
//

import Cocoa
import Foundation
import MySQL

class MySQLConnect: NSObject {
    
    var host = "127.0.0.1"
    var port = "8080"
    var user = "root"
    var password = "shaosikang"
    var dataBase = "test"
    
    private var mysql : MySQL!
    
    private static var instance : MySQL!
    
//    public static func shareInstance(dataBaseName : String) -> MySQL {
//        if instance == nil {
//            instance = MySQLConnect(dataBaseName : dataBaseName).mysql
//        }
//        return instance
//    }
    
    public static func shareInstance() -> MySQL {
        if instance == nil {
            instance = MySQLConnect().mysql
        }
        return instance
    }
    
    private override init() {
        super.init()
        self.connectDataBase()
    }
    
//    private init(dataBaseName : String) {
//        super.init()
//        self.connectDataBase()
//        self.selectDataBase(name : dataBaseName)
//    }
    
    private func connectDataBase() {
        if mysql == nil {
            mysql = MySQL()
        }
        let connected = mysql.connect(host : "\(host)", user: user, password: password, db: dataBase)
        guard connected else {
            NSLog("数据库连接失败 :%@", mysql.errorMessage())
            return
        }
        NSLog("数据库连接成功")
    }
    
//    func selectDataBase(name : String) {
//        guard mysql.selectDatabase(named: name) else {
//            NSLog("连接database失败 :%d :%@", mysql.errorCode() , mysql.errorMessage())
//            return
//        }
//        NSLog("连接database:%@成功", name)
//    }

}
