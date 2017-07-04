//
//  Call.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone

/// LinPhone Call class.
public final class Call {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<Call.UnmanagedPointer>
    
    // MARK: - Initialization
    
    internal init(_ managedPointer: ManagedPointer<Call.UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    // MARK: - Methods
    
    /// Accept an incoming call.
    ///
    /// Basically the application is notified of incoming calls within the `call state changed` callback, 
    /// where it will receive a `.incoming` event with the associated `Linphone.Call` object.
    ///
    /// The application can later accept the call using this method.
    public func accept() -> Bool {
        
        return linphone_call_accept(rawPointer) == .success
    }
    
    /// Resumes a call. 
    ///
    /// The call needs to have been paused previously with `pause()`.
    public func resume() -> Bool {
        
        return linphone_call_resume(rawPointer) == .success
    }
    
    // MARK: - Accessors
    
    // public var core: Core
    
    /// The call's current state.
    public var state: State {
        
        @inline(__always)
        get { return State(linphone_call_get_state(rawPointer)) }
    }
    
    /// Tell whether a call has been asked to autoanswer
    /// 
    /// - Returns: A boolean value telling whether the call has been asked to autoanswer.
    public var askedToAutoanswer: Bool {
        
        @inline(__always)
        get { return linphone_call_asked_to_autoanswer(rawPointer).boolValue }
    }
    
    public var 
}

// MARK: - Supporting Types

public extension Call {
    
    /// represents the different state a call can reach into.
    public enum State: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneCallState
        
        case idle /**< Initial call state */
        case incomingReceived /**< This is a new incoming call */
        case outgoingInit /**< An outgoing call is started */
        case outgoingProgress /**< An outgoing call is in progress */
        case outgoingRinging /**< An outgoing call is ringing at remote end */
        case outgoingEarlyMedia /**< An outgoing call is proposed early media */
        case connected /**< Connected, the call is answered */
        case streamsRunning /**< The media streams are established and running */
        case pausing /**< The call is pausing at the initiative of local end */
        case paused /**< The call is paused, remote end has accepted the pause */
        case resuming /**< The call is being resumed by local end */
        case refered /**< The call is being transfered to another party, resulting in a new outgoing call to follow immediately */
        case error /**< The call encountered an error */
        case end /**< The call ended normally */
        case pausedByRemote /**< The call is paused by remote end */
        case updatedByRemote /**< The call's parameters change is requested by remote end, used for example when video is added by remote */
        case incomingEarlyMedia /**< We are proposing early media to an incoming call */
        case updating /**< A call update has been initiated by us */
        case released /**< The call object is no more retained by the core */
        case earlyUpdatedByRemote /**< The call is updated by remote while not yet answered (early dialog SIP UPDATE received) */
        case earlyUpdating /**< We are updating the call while not yet answered (early dialog SIP UPDATE sent) */
    }
}

extension Call.State: CustomStringConvertible {
    
    public var description: String {
        
        return String(cString: linphone_call_state_to_string(self.linPhoneType))
    }
}

extension Call {
    
    /// Enum representing the status of a call.
    public enum Status: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneCallStatus
        
        /// The call was sucessful.
        case success
        
        /// The call was aborted.
        case aborted
        
        /// The call was missed (unanswered)
        case missed
        
        /// The call was declined, either locally or by remote end
        case declined
        
        /// The call was aborted before being advertised to the application - for protocol reasons.
        case earlyAborted
    }
}

// MARK: - ManagedHandle

extension Call: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_call_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_call_unref(rawPointer)
        }
    }
}

extension Call: UserDataHandle {
    
    static var userDataGetFunction: (OpaquePointer?) -> UnsafeMutableRawPointer? {
        return linphone_call_get_user_data
    }
    
    static var userDataSetFunction: (_ UnmanagedPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_call_set_user_data
    }
}
