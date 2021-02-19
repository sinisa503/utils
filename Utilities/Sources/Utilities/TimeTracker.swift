import Foundation

public class TimeTracker {
  
  private var lastUptime: TimeInterval?
  private let timeout: TimeInterval
  
  public init(timeout: TimeInterval) {
    self.timeout = timeout
  }
  
  public func trackCurrentTime() {
    lastUptime = systemUptime()
  }
  
  public func didTimeoutExpire() -> Bool {
    if let lastUptime = lastUptime {
      let elapsedTime = systemUptime() - lastUptime
      
      return (elapsedTime > timeout) ? true : false
    }
    
    return false
  }
}

extension TimeTracker {
  
  // TODO: Confirm this is good practice
  // Check if there is an easier and safer way to get system boot time
  // Also check if race condition (delay between user time change and bootTime refresh) can ever be met
  private func systemUptime() -> TimeInterval {
    var currentTime = time_t()
    var bootTime    = timeval()
    var mib         = [CTL_KERN, KERN_BOOTTIME]
    // NOTE: Use strideof(), NOT sizeof() to account for data structure
    // alignment (padding)
    // http://stackoverflow.com/a/27640066
    // https://devforums.apple.com/message/1086617#1086617
    var size = MemoryLayout<timeval>.stride
    let result = sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)
    if result != 0 {
      debugPrint("ERROR - \(#file):\(#function) - errno = \(result)")
      return 0
    }
    time(&currentTime)
    let uptime = currentTime - bootTime.tv_sec
    
    return TimeInterval(uptime)
  }
}
