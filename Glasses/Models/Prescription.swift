import Foundation

struct EyeData {
    var sphere: String = ""
    var cylinder: String = ""
    var axis: String = ""
    
    var activeAxis: Double {
        if let val = Double(axis) { return val }
        return 0
    }
}

struct Prescription {
    var od: EyeData = EyeData()
    var os: EyeData = EyeData()
    var pd: String = ""
    
    var recommendedFrames: Set<String> {
        let odS = abs(Double(od.sphere) ?? 0)
        let osS = abs(Double(os.sphere) ?? 0)
        let odC = abs(Double(od.cylinder) ?? 0)
        let osC = abs(Double(os.cylinder) ?? 0)
        
        let maxPower = max(odS, osS) + max(odC, osC)
        
        if maxPower >= 4.0 {
            return ["round", "oval"]
        }
        return []
    }
}
