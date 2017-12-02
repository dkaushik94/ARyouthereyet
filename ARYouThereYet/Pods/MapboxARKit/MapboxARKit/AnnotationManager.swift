import ARKit
import SpriteKit
import CoreLocation

@objc public protocol AnnotationManagerDelegate {
    
    @objc optional func node(for annotation: Annotation) -> SCNNode?
    @objc optional func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera)
    
}

public class AnnotationManager: NSObject {
    
    public private(set) var session: ARSession
    public private(set) var sceneView: ARSCNView?
    public private(set) var anchors = [ARAnchor]()
    public private(set) var annotationsByAnchor = [ARAnchor: Annotation]()
    public private(set) var annotationsByNode = [SCNNode: Annotation]()
    public var delegate: AnnotationManagerDelegate?
    public var originLocation: CLLocation?
    
    public var xValues : [Float] = []
    public var zValues : [Float] = []
    
    public var ystretchValue : Int = 5
    
    public var directionDict  = [String : [Int]]()
    
    public init(session: ARSession) {
        self.session = session
    }
    
    convenience public init(sceneView: ARSCNView) {
        self.init(session: sceneView.session)
        session = sceneView.session
        sceneView.delegate = self
    }
    
    public func addAnnotation(annotation: Annotation) {
        guard let originLocation = originLocation else {
            print("Warning: \(type(of: self)).\(#function) was called without first setting \(type(of: self)).originLocation")
            return
        }
        
        // Create a Mapbox AR anchor anchor at the transformed position
        let anchor = MBARAnchor(originLocation: originLocation, location: annotation.location)
        
        // Add the anchor to the session
        session.add(anchor: anchor)
        
        anchors.append(anchor)
        annotation.anchor = anchor
        
        annotationsByAnchor[anchor] = annotation
    }
    
    public func addAnnotations(annotations: [Annotation]) {
        for annotation in annotations {
            addAnnotation(annotation: annotation)
        }
    }
    
    public func removeAllAnnotations() {
        for anchor in anchors {
            session.remove(anchor: anchor)
        }
        
        anchors.removeAll()
        annotationsByAnchor.removeAll()
    }
    
    public func removeAnnotations(annotations: [Annotation]) {
        for annotation in annotations {
            removeAnnotation(annotation: annotation)
        }
    }
    
    public func removeAnnotation(annotation: Annotation) {
        if let anchor = annotation.anchor {
            session.remove(anchor: anchor)
            anchors.remove(at: anchors.index(of: anchor)!)
            annotationsByAnchor.removeValue(forKey: anchor)
        }
    }
    
}

// MARK: - ARSCNViewDelegate

extension AnnotationManager: ARSCNViewDelegate {
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        delegate?.session?(session, cameraDidChangeTrackingState: camera)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Handle MBARAnchor
        if let anchor = anchor as? MBARAnchor {
            let annotation = annotationsByAnchor[anchor]!
            
            var newNode: SCNNode!
            
            // If the delegate supplied a node then use that, otherwise provide a basic default node
            if let suppliedNode = delegate?.node?(for: annotation) {
                newNode = suppliedNode
            } else {
                newNode = createDefaultNode()
            }
            
            

            if(newNode.name != "NavigationNode") {
            
                newNode.position = SCNVector3(Float(anchor.transform.columns.3.x),Float(anchor.transform.columns.3.y), -abs(Float(anchor.transform.columns.3.z)))
                
                var yIncreaseValue = 0
                
                if(!(xValues.count == 0) && !(zValues.count == 0)) {
                    let x = anchor.transform.columns.3.x
                    let z = anchor.transform.columns.3.z
                    
                    for i in 0..<xValues.count {
                        let xRatio = x/xValues[i]
                        let zRatio = z/zValues[i]
                        let mainRatio = 1-abs(xRatio-zRatio)
                        print(xRatio/zRatio)
                        if(mainRatio > 0.6) {
                            ystretchValue = 0
                            print("Has another node in almost same direction")
                            let keys = directionDict.keys
                            if(keys.count != 0) {
                                for key in keys {
                                    if(directionDict[key]?.contains(i))! {
                                        // There is a node in this direction already noted
                                        let Y = 0.1130 * abs(anchor.transform.columns.3.z) + 9.574
                                        ystretchValue = (directionDict[key]?.count)! * Int(Y) + (-150)
                                        directionDict[key]?.append(xValues.count)
                                        break
                                    }
                                }
                                let currentKey = String(directionDict.keys.count)
                                directionDict[currentKey] = [Int]()
                                directionDict[currentKey]?.append(xValues.count)
                                directionDict[currentKey]?.append(i)
                            } else{
                                let currentKey = String(directionDict.keys.count)
                                directionDict[currentKey] = [Int]()
                                directionDict[currentKey]?.append(xValues.count)
                                directionDict[currentKey]?.append(i)
                                ystretchValue = -200
                            }
                            yIncreaseValue = ystretchValue
                            newNode.position.y = newNode.position.y + Float(ystretchValue)
                        }
                    }
                }
                
                let realDistance = sqrt(pow(abs(anchor.transform.columns.3.z), 2.0) + Float(pow(Double(abs(yIncreaseValue)), 2.0)))
                
                //            let linS = 4.13778 + 0.17944 * abs(anchor.transform.columns.3.z)
                //            let linS = 8.41220 + 0.18595 * abs(anchor.transform.columns.3.z)
                let linS = 8.41220 + 0.18595 * realDistance
                

                //            let scalingFactor = 0.018403680735972+0.015963192638528 * abs(anchor.transform.columns.3.z)
                let newS = 45.0/426.0
                //            let scalingFactor = 45
                let scalingFactor = newS * Double(abs(anchor.transform.columns.3.z))
                
                
                
                let f = 0.579 * powf(abs(anchor.transform.columns.3.z), 0.806)
                
                //            newNode.scale = SCNVector3(scalingFactor, scalingFactor, scalingFactor)
                newNode.scale = SCNVector3(linS, linS, linS)
                print("SCALING for distance:\(anchor.transform.columns.3.z) :  \(linS)")
                
                xValues.append(anchor.transform.columns.3.x)
                zValues.append(anchor.transform.columns.3.z)

            }

            
            if let calloutImage = annotation.calloutImage {
                let calloutNode = createCalloutNode(with: calloutImage, node: newNode)
                newNode.addChildNode(calloutNode)
            }
            node.addChildNode(newNode)
            annotationsByNode[newNode] = annotation
        }
        
    }
    
    // MARK: - Utility methods for ARSCNViewDelegate
    
    func createDefaultNode() -> SCNNode {
        let sphere = SCNSphere(radius: 2.0)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        return SCNNode(geometry: sphere)
    }
    
    func createCalloutNode(with image: UIImage, node: SCNNode) -> SCNNode {
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if image.size.width >= image.size.height {
            width = image.size.width / image.size.height
            height = 1.0
        } else {
            width = 1.0
            height = image.size.height / image.size.width
        }
        
        let calloutGeometry = SCNPlane(width: width, height: height)
        calloutGeometry.firstMaterial?.diffuse.contents = image
        
        let calloutNode = SCNNode(geometry: calloutGeometry)
        var nodePosition = node.position
        let (min, max) = node.boundingBox
        let nodeHeight = max.y - min.y
        nodePosition.y = nodeHeight + 2.0
        
        calloutNode.position = nodePosition
        
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = [.Y]
        calloutNode.constraints = [constraint]
        
        return calloutNode
    }
}
