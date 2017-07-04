//
//  InternalEnum.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 6/30/17.
//
//

public protocol LinPhoneEnumeration: RawRepresentable {
    
    associatedtype LinPhoneType: RawRepresentable
    
    init?(_ linPhoneType: LinPhoneType)
    
    var linPhoneType: LinPhoneType { get }
}

public extension LinPhoneEnumeration where Self.RawValue == LinPhoneType.RawValue {
    
    init(_ linPhoneType: LinPhoneType) {
        
        self.init(rawValue: linPhoneType.rawValue)!
    }
    
    var linPhoneType: LinPhoneType {
        
        return LinPhoneType(rawValue: self.rawValue)!
    }
}
