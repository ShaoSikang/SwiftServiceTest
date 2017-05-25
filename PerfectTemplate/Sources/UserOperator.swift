//
//  UserOperator.swift
//  PerfectTemplate
//
//  Created by Sikang Shao on 2017/5/5.
//
//

import Cocoa

class UserOperator: BaseOperator {

    let userTableName = "user"
    
    func insertUserInfo(userName : String, password : String) -> String? {
        let exist = queryUserExist(userName: userName)
        if exist {
            self.responseJson[ResultKey] = RequestResultFail
            self.responseJson[ErrorMessageKey] = "用户 '\(userName)' 已经存在"
            guard let json = try? responseJson.jsonEncodedString() else {
                return nil
            }
            return json
        }
        let values = "('\(userName)', '\(password)')"
        let statement = "insert into \(userTableName) (username, password) values \(values)"
        if !mysql.query(statement: statement) {
            self.responseJson[ResultKey] = RequestResultFail
            self.responseJson[ErrorMessageKey] = "添加用户\(userName)失败"
            guard let json = try? responseJson.jsonEncodedString() else {
                return nil
            }
            return json
        } else {
            return queryUserInfo(userName: userName)
        }
        
    }
    
    func deleteUser(userId : String) -> String? {
        let statement = "delete from \(userTableName) where id = '\(userId)'"
        if !mysql.query(statement: statement) {
            self.responseJson[ResultKey] = RequestResultFail
            self.responseJson[ErrorMessageKey] = "删除失败"
        } else {
            self.responseJson[ResultKey] = RequestResultSuccess
        }
        guard let json = try? responseJson.jsonEncodedString() else {
            return nil
        }
        return json
    }
    
    func updateUserInfo(userId : String, userName : String, password : String) -> String? {
        let statement = "update \(userTableName) set username = '\(userName)', password = '\(password)', create_time = now() where id = '\(userId)'"
        if !mysql.query(statement: statement) {
            self.responseJson[ResultKey] = RequestResultFail
            self.responseJson[ErrorMessageKey] = "更新失败"
        } else {
            self.responseJson[ResultKey] = RequestResultSuccess
        }
        guard let json = try? responseJson.jsonEncodedString() else {
            return nil
        }
        return json
    }
    
    func queryUserInfo(userName : String) -> String? {
        let statement = "select * from \(userTableName) where username = '\(userName)'"
        if !mysql.query(statement: statement) {
            self.responseJson[ResultKey] = RequestResultFail
            self.responseJson[ErrorMessageKey] = "查询失败"
        } else {
            let results = mysql.storeResults()!
            var dic = [String : String]()
            results.forEachRow(callback: { (row) in
                guard let  userId = row.first! else {
                    return
                }
                dic["userId"] = "\(userId)"
                dic["userName"] = "\(row[1]!)"
                dic["password"] = "\(row[2]!)"
                dic["create_time"] = "\(row[3]!)"
            })
            self.responseJson[ResultKey] = RequestResultSuccess
            self.responseJson[ResultListKey] = dic
        }
        guard let json = try? responseJson.jsonEncodedString() else {
            return nil
        }
        return json
    }
    
    func queryUserExist(userName: String) -> Bool {
        let statement = "select 1 from \(userTableName) where username = '\(userName)'"
        if !mysql.query(statement: statement) {
            return true
        } else {
            let results = mysql.storeResults()!
            return results.numRows() > 0
        }
    }
    
}
