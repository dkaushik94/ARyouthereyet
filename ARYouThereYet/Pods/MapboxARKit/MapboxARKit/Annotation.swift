import CoreLocation

public class Annotation: NSObject {
    
    public var location: CLLocation
    public var calloutImage: UIImage?
    public var anchor: MBARAnchor?
    public var name: String
    
    public init(location: CLLocation, calloutImage: UIImage?, name: String) {
        self.location = location
        self.calloutImage = calloutImage
        self.name = name
    }
}
