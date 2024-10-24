import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var locationCompletion: (([String: Any]) -> Void)?

    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
    }

    // Phương thức để kiểm tra quyền truy cập vị trí
    private func checkLocationAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Nếu đã có quyền, gọi để lấy vị trí
            getCurrentLocation { _ in }
        case .denied:
            // Quyền bị từ chối, gửi thông báo lỗi
            self.locationCompletion?(["error": "Location access denied"])
        case .notDetermined:
            // Xin quyền truy cập
            self.locationManager?.requestWhenInUseAuthorization()
        case .restricted:
            // Dịch vụ vị trí bị hạn chế, gửi thông báo lỗi
            self.locationCompletion?(["error": "Location services are restricted"])
        @unknown default:
            break
        }
    }

    func getCurrentLocation(completion: @escaping ([String: Any]) -> Void) {
        self.locationCompletion = completion
        
        // Kiểm tra dịch vụ vị trí
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager?.startUpdatingLocation()
        } else {
            completion(["error": "Location services are not enabled"])
        }
    }

    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Tạo một Map<String, Any> và gọi callback
        let locationData: [String: Any] = ["latitude": latitude, "longitude": longitude]
        self.locationCompletion?(locationData)
        
        // Dừng cập nhật vị trí ngay lập tức sau khi lấy vị trí
      //   self.locationManager?.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        self.locationCompletion?(["error": "Unable to get location"])
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Khi quyền truy cập thay đổi, kiểm tra lại
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            getCurrentLocation { _ in }
        } else {
            self.locationCompletion?(["error": "Location access denied"])
        }
    }
}
