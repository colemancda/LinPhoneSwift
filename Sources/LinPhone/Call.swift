//
//  Call.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone.core
import CBelledonneToolbox.port

/// LinPhone Call class.
public final class Call {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    deinit {
        
        clearUserData()
    }
    
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    // MARK: - Accessors
    
    /// Get the `Linphone.Core` object that has created the specified call.
    public var core: Core? {
        
        guard let rawPointer = linphone_call_get_core(self.rawPointer),
            let handle = Core.from(rawPointer: rawPointer)
            else { return nil }
        
        return handle
    }
    
    /// Gets the transferer if this call was started automatically as a result of an incoming transfer request.
    /// The call in which the transfer request was received is returned in this case.
    /// 
    /// - Returns: The transferer call if the specified call was started automatically as a result of
    /// an incoming transfer request or `nil` otherwise.
    public var transferer: Call? {
        
        return getUserDataHandle(shouldRetain: true, linphone_call_get_transferer_call)
    }
    
    /// When this call has received a transfer request, returns the new call that was automatically created 
    /// as a result of the transfer.
    public var transferTarget: Call? {
        
        return getUserDataHandle(shouldRetain: true, linphone_call_get_transfer_target_call)
    }
    
    /// Returns the call object this call is replacing, if any. 
    ///
    /// Call replacement can occur during call transfers. 
    /// By default, the `Core` automatically terminates the replaced call and accept the new one. 
    /// This property allows the application to know whether a new incoming call is a one that replaces another one.
    public var replaced: Call? {
        
        return getUserDataHandle(shouldRetain: true, linphone_call_get_replaced_call)
    }
    
    /// Returns the remote address associated to this call.
    public var remoteAddress: Address {
        
        return getReferenceConvertible(.externallyRetainedImmutable, linphone_call_get_remote_address)! // never nil
    }
    
    /// Returns the 'to' address with its headers associated to this call.
    public var toAddress: Address {
        
        return getReferenceConvertible(.externallyRetainedImmutable, linphone_call_get_to_address)!
    }
    
    /// Returns the diversion address associated to this call.
    public var diversionAddress: Address? {
        
        return getReferenceConvertible(.externallyRetainedImmutable, linphone_call_get_diversion_address)
    }
    
    /// Details about call errors or termination reasons.
    public var errorInfo: ErrorInfo? {
        
        return getReferenceConvertible(.copy, linphone_call_get_error_info)
    }
    
    /// Execute closure on next video frame decoded.
    public var nextVideoFrameDecoded: ((Call) -> ())? {
        
        didSet {
            
            if nextVideoFrameDecoded != nil {
                
                linphone_call_set_next_video_frame_decoded_callback(rawPointer, { (rawPointer, _) in
                    
                    guard let rawPointer = rawPointer,
                        let call = Call.from(rawPointer: rawPointer)
                        else { return }
                    
                    call.nextVideoFrameDecoded?(call)
                    
                    call.nextVideoFrameDecoded = nil // reset in Swift, C object already resets internally
                    
                }, nil)
                
            } else {
                
                linphone_call_set_next_video_frame_decoded_callback(rawPointer, nil, nil)
            }
        }
    }
    
    /// The native video window id where the video is to be displayed.
    public var nativeWindow: CallNativeWindow? {
        
        didSet {
            
            linphone_call_set_native_video_window_id(rawPointer, nativeWindow?.toNativeHandle())
        }
    }
    
    /// The current parameters associated to the call.
    public var parameters: Parameters {
        
        get { return getReferenceConvertible(.copy, linphone_call_get_current_params)! }
        
        //set { return setReferenceConvertible(copy: true, linphone_call_set_params, newValue) }
    }
    
    /// The call's current state.
    public var state: State {
        
        get { return State(linphone_call_get_state(rawPointer)) }
    }
    
    /// Tell whether a call has been asked to autoanswer
    /// 
    /// - Returns: A boolean value telling whether the call has been asked to autoanswer.
    public var askedToAutoanswer: Bool {
        
        get { return linphone_call_asked_to_autoanswer(rawPointer).boolValue }
    }
    
    /// Returns the remote address associated to this call.
    public var remoteAddressString: String? {
        
        get { return getString(linphone_call_get_remote_address_as_string) }
    }
    
    /// Returns call's duration in seconds.
    public var duration: Int {
        
        get { return Int(linphone_call_get_duration(rawPointer)) }
    }
    
    /// Returns direction of the call (incoming or outgoing).
    public var direction: Direction {
        
        get { return Direction(linphone_call_get_dir(rawPointer)) }
    }
    
    //public var log: Call.Log 
    // linphone_call_get_call_log
    
    /// Gets the refer-to uri (if the call was transfered).
    public var referTo: String? {
        
        get { return getString(linphone_call_get_refer_to) }
    }
    
    /// Returns `true` if this calls has received a transfer that has not been executed yet. 
    /// Pending transfers are executed when this call is being paused or closed, locally or by remote endpoint. 
    /// If the call is already paused while receiving the transfer request, the transfer immediately occurs.
    public var hasTransferPending: Bool {
        
        get { return linphone_call_has_transfer_pending(rawPointer).boolValue }
    }
    
    /// Indicates whether camera input should be sent to remote end.
    public var isCameraEnabled: Bool {
        
        get { return linphone_call_camera_enabled(rawPointer).boolValue }
        
        set { linphone_call_enable_camera(rawPointer, bool_t(newValue)) }
    }
    
    /// Returns the reason for a call termination (either error or normal termination)
    public var reason: Reason {
        
        get { return Reason(linphone_call_get_reason(rawPointer)) }
    }
    
    /// Returns the far end's user agent description string, if available.
    public var remoteUserAgent: String? {
        
        get { return getString(linphone_call_get_remote_user_agent) }
    }
    
    /// Returns the far end's sip contact as a string, if available.
    public var remoteContact: String? {
        
        get { return getString(linphone_call_get_remote_contact) }
    }
    
    /// The ZRTP authentication token to verify.
    public var authenticationToken: String? {
        
        get { return getString(linphone_call_get_authentication_token) }
    }
    
    /// Whether ZRTP authentication token is verified. 
    /// If not, it must be verified by users as described in ZRTP procedure.
    public var authenticationTokenVerified: Bool {
        
        get { return linphone_call_get_authentication_token_verified(rawPointer).boolValue }
        
        set { linphone_call_set_authentication_token_verified(rawPointer, bool_t(newValue)) }
    }
    
    /*
    public var isInConference: Bool {
        
        get { return linphone_call_is_in_conference(rawPointer).boolValue }
    }*/
    
    /// Obtain real-time quality rating of the call.
    ///
    /// Based on local RTP statistics and RTCP feedback, a quality rating is computed and updated 
    /// during all the duration of the call. This function returns its value at the time of the function call.
    /// It is expected that the rating is updated at least every 5 seconds or so. 
    /// The rating is a floating point number comprised between 0 and 5. For Example:
    /// * 4-5 = good quality
    /// * 3-4 = average quality
    /// * 2-3 = poor quality
    /// * 1-2 = very poor quality
    /// * 0-1 = can't be worse, mostly unusable
    public var currentQuality: Float {
        
        get { return linphone_call_get_current_quality(rawPointer) }
    }
    
    /// Returns the number of stream for the given call. 
    ///
    /// Currently there is only two (Audio, Video), but later there will be more.
    public var streamCount: Int {
        
        get { return Int(linphone_call_get_stream_count(rawPointer)) }
    }
    
    // MARK: - Methods
    
    /// Accept an incoming call.
    ///
    /// Basically the application is notified of incoming calls within the `call state changed` callback,
    /// where it will receive a `.incomingReceived` event with the associated `Linphone.Call` object.
    ///
    /// The application can later accept the call using this method.
    @discardableResult
    public func accept() -> Bool {
        
        return linphone_call_accept(rawPointer) == .success
    }
    
    /// Pauses the call.
    ///
    /// If a music file has been setup using `Linphone.Core.setPlayFile()`, this file will be played to the remote user.
    /// The only way to resume a paused call is to call `resume()`.
    @discardableResult
    public func pause() -> Bool {
        
        return linphone_call_pause(rawPointer) == .success
    }
    
    /// Resumes a call.
    ///
    /// The call needs to have been paused previously with `pause()`.
    @discardableResult
    public func resume() -> Bool {
        
        return linphone_call_resume(rawPointer) == .success
    }
    
    /// Terminates a call.
    @discardableResult
    public func terminate() -> Bool {
        
        return linphone_call_terminate(rawPointer) == .success
    }
    
    /// Take a photo of currently received video and write it into a jpeg file. 
    /// Note that the snapshot is asynchronous, an application shall not assume 
    /// that the file is created when the method returns.
    @discardableResult
    public func takeVideoSnapshot(file: String) -> Bool {
        
        return linphone_call_take_video_snapshot(rawPointer, file) == .success
    }
    
    /// Take a photo of currently captured video and write it into a jpeg file. 
    /// Note that the snapshot is asynchronous, an application shall not assume 
    /// that the file is created when the function returns.
    @discardableResult
    public func takePreviewSnapshot(file: String) -> Bool {
        
        return linphone_call_take_preview_snapshot(rawPointer, file) == .success
    }
    
    /// Request remote side to send us a Video Fast Update.
    public func sendVideoFastUpdateRequest() {
        
        linphone_call_send_vfu_request(rawPointer)
    }
    
    /// Send the specified dtmf.
    /// The dtmf is automatically played to the user.
    /// - Parameter dtmf: The dtmf name specified as a char, such as '0', '#' etc...
    @discardableResult
    public func send(dtmf: Int8) -> Bool {
        
        return linphone_call_send_dtmf(rawPointer, dtmf) == .success
    }
    
    /// Perform a zoom of the video displayed during a call.
    /// `center` is updated in case its coordinates were too excentrated for the requested zoom factor.
    /// The zoom ensures that all the screen is fullfilled with the video. 
    public func zoomVideo(factor: Float, center: inout (x: Float, y: Float)) {
        
        linphone_call_zoom_video(rawPointer, factor, &center.x, &center.y)
    }
    
    /// Return a copy of the call statistics for a particular stream type.
    public func stats(for type: StreamType) -> Call.Stats? {
        
        guard let reference = getManagedHandle(shouldRetain: false, { linphone_call_get_stats($0, type.linPhoneType) }) as Call.Stats.Reference?
            else { return nil }
        
        return Call.Stats(referencing: reference)
    }
    
    /// Returns the type of stream for the given stream index.
    public func streamType(at index: Int) -> StreamType {
        
        let formatType = linphone_call_get_stream_type(rawPointer, Int32(index))
        
        return StreamType(rawValue: formatType.rawValue)!
    }
}

// MARK: - Supporting Types

public extension Call {
    
    /// represents the different state a call can reach into.
    public enum State: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneCallState
        
        /// Initial call state
        case idle
        
        /// This is a new incoming call
        case incomingReceived
        
        /// An outgoing call is started
        case outgoingInit
        
        /// An outgoing call is in progress
        case outgoingProgress
        
        /// An outgoing call is ringing at remote end
        case outgoingRinging
        
        /// An outgoing call is proposed early media
        case outgoingEarlyMedia
        
        /// Connected, the call is answered
        case connected
        
        /// The media streams are established and running
        case streamsRunning
        
        /// The call is pausing at the initiative of local end
        case pausing
        
        /// The call is paused, remote end has accepted the pause
        case paused
        
        /// The call is being resumed by local end
        case resuming
        
        /// The call is being transfered to another party, resulting in a new outgoing call to follow immediately
        case refered
        
        /// The call encountered an error
        case error
        
        /// The call ended normally
        case end
        
        /// The call is paused by remote end
        case pausedByRemote
        
        /// The call's parameters change is requested by remote end, used for example when video is added by remote
        case updatedByRemote
        
        /// We are proposing early media to an incoming call
        case incomingEarlyMedia
        
        /// A call update has been initiated by us
        case updating
        
        /// The call object is no more retained by the core
        case released
        
        /// The call is updated by remote while not yet answered (early dialog SIP UPDATE received)
        case earlyUpdatedByRemote
        
        /// We are updating the call while not yet answered (early dialog SIP UPDATE sent)
        case earlyUpdating
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
        
        /// The call was declined, either locally or by remote end.
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

public protocol CallNativeWindow {
    
    func toNativeHandle() -> UnsafeMutableRawPointer
}

#if os(iOS)
    
    import class UIKit.UIView
    
    extension UIView: CallNativeWindow {
        
        public func toNativeHandle() -> UnsafeMutableRawPointer {
            
            return Unmanaged.passUnretained(self).toOpaque()
        }
    }
#endif

#if os(macOS)
    
    import class AppKit.NSView
    
    extension NSView: CallNativeWindow {
        
        public func toNativeHandle() -> UnsafeMutableRawPointer {
            
            return Unmanaged.passUnretained(self).toOpaque()
        }
    }
#endif

public extension Call {
    
    /// That class holds all the callbacks which are called by `Linphone.Core`.
    public final class Callbacks {
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        deinit {
            
            clearUserData()
        }
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        public convenience init(factory: Factory = Factory.shared) {
            
            guard let rawPointer = linphone_factory_create_core_cbs(factory.rawPointer)
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
            self.setUserData()
        }
        
        // MARK: - Accessors
        
        /// Call state notification callback.
        public var stateChanged: ((_ call: Call, _ state: Call.State, _ message: String?) -> ())? {
            
            didSet {
                
                linphone_call_cbs_set_state_changed(rawPointer) {
                    
                    guard let (call, callbacks) = Call.callbacksFrom(rawPointer: $0.0)
                        else { return }
                    
                    let state = Call.State($0.1)
                    
                    let message = String(lpCString: $0.2)
                    
                    callbacks.stateChanged?(call, state, message)
                }
            }
        }
    }
}

// MARK: - ManagedHandle

extension Call: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhoneSwift.UnmanagedPointer {
        
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

extension Call.Callbacks: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhoneSwift.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_call_cbs_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_call_cbs_unref(rawPointer)
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

extension Call.Callbacks: UserDataHandle {
    
    static var userDataGetFunction: (OpaquePointer?) -> UnsafeMutableRawPointer? {
        return linphone_call_cbs_get_user_data
    }
    
    static var userDataSetFunction: (_ UnmanagedPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_call_cbs_set_user_data
    }
}

extension Call: CallBacksHandle {
    
    static var currentCallbacksFunction: (RawPointer?) -> (Callbacks.RawPointer?) { return linphone_call_get_current_callbacks }
}
