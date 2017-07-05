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
    
    @inline(__always)
    private func getAddress(_ function: (RawPointer?) -> Address.Reference.RawPointer?) -> Address? {
        
        // get handle pointer
        guard let rawPointer = function(self.rawPointer)
            else { return nil }
        
        // create swift object for address
        let reference = Address.Reference(ManagedPointer(Address.UnmanagedPointer(rawPointer)))
        
        // Object is already retained externally by the reciever,
        // so we must copy / clone the reference object on next mutation regardless of ARC uniqueness / retain count,
        // this is more efficient than unnecesarily copying right now, since the object may never be mutated.
        //
        // If we dont copy or set this flag, and the struct is modified with its reference object
        // uniquely retained (at least according to ARC), we will be mutating  the internal handle
        // shared by the reciever and possibly other C objects, which would lead to bugs
        // and violate value semantics for reference-backed value types.
        let address = Address(reference, externalRetain: true)
        
        return address
    }
    
    /// Returns the remote address associated to this call.
    public var remoteAddress: Address? {
        
        return getAddress(linphone_call_get_remote_address)
    }
    
    /// Returns the remote address associated to this call.
    public var remoteAddressString: String? {
        
        @inline(__always)
        get { return getString(linphone_call_get_remote_address_as_string) }
    }
    
    /*
    /// Returns the 'to' address with its headers associated to this call.
    public var toAddress: Address? {
        
        return getAddress(linphone_call_get_to_address)
    }*/
    
    /// Returns the diversion address associated to this call.
    public var diversionAddress: Address? {
        
        return getAddress(linphone_call_get_diversion_address)
    }
    
    /// Returns call's duration in seconds.
    public var duration: Int {
        
        @inline(__always)
        get { return Int(linphone_call_get_duration(rawPointer)) }
    }
    
    /// Returns direction of the call (incoming or outgoing).
    public var direction: Direction {
        
        @inline(__always)
        get { return Direction(linphone_call_get_dir(rawPointer)) }
    }
    
    //public var log: Call.Log 
    // linphone_call_get_call_log
    
    /// Gets the refer-to uri (if the call was transfered).
    public var referTo: String? {
        
        @inline(__always)
        get { return getString(linphone_call_get_refer_to) }
    }
    
    /// Returns `true` if this calls has received a transfer that has not been executed yet. 
    /// Pending transfers are executed when this call is being paused or closed, locally or by remote endpoint. 
    /// If the call is already paused while receiving the transfer request, the transfer immediately occurs.
    public var hasTransferPending: Bool {
        
        @inline(__always)
        get { return linphone_call_has_transfer_pending(rawPointer).boolValue }
    }
    
    /// Indicates whether camera input should be sent to remote end.
    public var isCameraEnabled: Bool {
        
        @inline(__always)
        get { return linphone_call_camera_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_call_enable_camera(rawPointer, bool_t(newValue)) }
    }
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

extension Call {
    
    public enum Direction: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneCallDir
        
        case outgoing
        case incoming
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
