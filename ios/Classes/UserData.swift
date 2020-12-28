//
//  UserData.swift
//  bluetooth_peripheral
//
//  Created by Maximilian Nitsche on 27.08.20.
//

import Foundation

class UserData {
    private var _userId: String
    private var _username: String
    private var _displayName: String
    
    init(userId: String, username: String, displayName: String) {
        self._userId = userId
        self._username = username
        self._displayName = displayName
    }
    
    var userId: Data? {
        get { return _userId.data(using: .utf8)!}
    }
    
    var username: Data? {
        get { return _username.data(using: .utf8)!}
    }
    
    var displayName: Data? {
        get { return _displayName.data(using: .utf8)!}
    }

}

