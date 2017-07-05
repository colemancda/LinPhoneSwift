//
//  Reason.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/5/17.
//
//

import CLinPhone

/// Enum describing various failure reasons or contextual information for some events.
public enum Reason: UInt32, LinPhoneEnumeration {
    
    public typealias LinPhoneType = LinphoneReason
    
    /// No reason has been set by the `Core`
    case none
    
    /// No response received from remote
    case noResponse
    
    /// Authentication failed due to bad credentials or resource forbidden
    case forbidden
    
    /// The call has been declined
    case declined
    
    /// Destination of the call was not found
    case notFound
    
    /// The call was not answered in time (request timeout)
    case notAnswered
    
    /// Phone line was busy
    case busy
    
    /// Unsupported content
    case unsupportedContent
    
    /// Transport error: connection failures, disconnections etc...
    case inputOutputError
    
    /// Do not disturb reason
    case doNotDisturb
    
    /// Operation is unauthorized because missing credential
    case unauthorized
    
    /// Operation is rejected due to incompatible or unsupported media parameters
    case notAcceptable
    
    /// Operation could not be executed by server or remote client because it didn't have any context for it
    case noMatch
    
    /// Resource moved permanently
    case movedPermanently
    
    /// Resource no longer exists
    case gone
    
    /// Temporarily unavailable
    case temporarilyUnavailable
    
    /// Address incomplete
    case addressIncomplete
    
    /// Not implemented
    case notImplemented
    
    /// Bad gateway
    case badGateway
    
    /// Server timeout
    case serverTimeout
    
    /// Unknown reason
    case unknown
    
    // backwards compatibility
    
    static let badCredentials: Reason = .forbidden // LinphoneReasonBadCredentials
    
    static let media: Reason = .unsupportedContent // LinphoneReasonMedia
}

// MARK: - ErrorCode

public typealias ErrorCode = Int32

public extension Reason {
    
    /// Converts an error code to a `Linphone.Reason`.
    init(errorCode: ErrorCode) {
        
        self.init(linphone_error_code_to_reason(errorCode))
    }
    
    /// Converts a `Linphone.Reason` to an error code.
    /// 
    /// - Returns: The error code corresponding to the specified `Linphone.Reason`.
    var errorCode: ErrorCode {
        
        @inline(__always)
        get { return linphone_reason_to_error_code(linPhoneType) }
    }
}

// MARK: - CustomStringConvertible

extension Reason: CustomStringConvertible {
    
    public var description: String {
        
        @inline(__always)
        get { return String(cString: linphone_reason_to_string(linPhoneType)) }
    }
}
