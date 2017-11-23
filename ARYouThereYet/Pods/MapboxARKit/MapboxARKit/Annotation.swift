import CoreLocation

public class Annotation: NSObject {
    
    public var location: CLLocation
    public var calloutImage: UIImage?
    public var anchor: MBARAnchor?
    public var name: String
    public var reference: String
    public var address: String
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    public var distance: Double
    public var rating: Double
    public var icon: UIImage
    
    public init(location: CLLocation, calloutImage: UIImage?, name: String, reference: String, address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, distance: Double, rating: Double, icon: UIImage) {
        self.location = location
        self.calloutImage = calloutImage
        self.name = name
        self.reference = reference
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
        self.rating = rating
        self.icon = icon
    }
}
