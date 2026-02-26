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
    
    // Calculates the true maximum optical power across both eyes
    var maxPowerString: String? {
        let odSph = Double(od.sphere.replacingOccurrences(of: "+", with: "")) ?? 0
        let odCyl = Double(od.cylinder.replacingOccurrences(of: "+", with: "")) ?? 0
        let osSph = Double(os.sphere.replacingOccurrences(of: "+", with: "")) ?? 0
        let osCyl = Double(os.cylinder.replacingOccurrences(of: "+", with: "")) ?? 0
        
        let odMax = abs(odSph) > abs(odSph + odCyl) ? odSph : (odSph + odCyl)
        let osMax = abs(osSph) > abs(osSph + osCyl) ? osSph : (osSph + osCyl)
        
        let highestPower = abs(odMax) > abs(osMax) ? odMax : osMax
        
        if abs(highestPower) >= 4.0 {
            return String(format: "%+.2f", highestPower)
        }
        return nil
    }
    
    // Checks if the PD is considered narrow (less than 58mm)
    var narrowPDValue: Double? {
        if let pdValue = Double(pd), pdValue > 0, pdValue < 58.0 {
            return pdValue
        }
        return nil
    }
    
    // Generates the active list of reasons for our UI blurb
    var recommendationReasons: [String] {
        var reasons: [String] = []
        if let power = maxPowerString {
            reasons.append("prescription reaches \(power)")
        }
        if let pdVal = narrowPDValue {
            reasons.append("PD is narrow (\(pdVal) mm)")
        }
        return reasons
    }
    
    // Combines the optical rules to filter the perfect frames
    var recommendedFrames: Set<String> {
        let allFrames = Set(["aviator", "browline", "cateye", "geometric", "oval", "oversized", "rectangle", "round", "square"])
        var filteredFrames = allFrames
        var hasFilter = false
        
        // Rule 1: High Rx needs small, round frames to hide edge thickness
        if maxPowerString != nil {
            filteredFrames.formIntersection(["round", "oval"])
            hasFilter = true
        }
        
        // Rule 2: Narrow PD needs to avoid wide frames to keep eyes centered
        if narrowPDValue != nil {
            filteredFrames.subtract(["oversized", "aviator"])
            hasFilter = true
        }
        
        return hasFilter ? filteredFrames : []
    }
}
