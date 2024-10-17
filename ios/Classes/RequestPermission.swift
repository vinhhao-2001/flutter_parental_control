import FamilyControls
import CloudKit

@available(iOS 16.0, *)
class RequestPermission {
    
    // Kiểm tra trạng thái uỷ quyền của thiết bị
    func checkParentalControl() async -> String {
        let center = AuthorizationCenter.shared
        do {
            let iCloudAvailable = try await self.checkICloudStatus()
            
            if iCloudAvailable {
                try await center.requestAuthorization(for: FamilyControlsMember.child)
                
                switch center.authorizationStatus {
                case .notDetermined:
                    return AppConstants.AUTH_NOT_DETERMINED // Trạng thái ủy quyền chưa xác định
                case .denied:
                    return AppConstants.AUTH_DENIED // Trạng thái ủy quyền bị từ chối
                case .approved:
                    return AppConstants.AUTH_APPROVED // Trạng thái ủy quyền được chấp nhận
                @unknown default:
                    return AppConstants.UNKNOWN_AUTH_STATUS // Trạng thái ủy quyền không xác định
                }
            } else {
                return AppConstants.NO_ICLOUD_ACCOUNT // Không có tài khoản iCloud hoặc chưa đăng nhập
            }
        } catch FamilyControlsError.invalidAccountType {
            return AppConstants.INVALID_ACCOUNT_TYPE // Tài khoản iCloud không phải của trẻ em
        } catch FamilyControlsError.authorizationCanceled {
            return AppConstants.AUTHORIZATION_CANCELED // Quyền bị hủy do không phải cha mẹ hoặc người giám hộ
        } catch {
            return AppConstants.UNKNOWN_ERROR // Lỗi không xác định xảy ra
        }
    }
    
    // kiểm tra trạng thái đăng nhập tài khoản iCloud
    private func checkICloudStatus() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            let container = CKContainer.default()
            container.accountStatus { (accountStatus, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    switch accountStatus {
                    case .available:
                        continuation.resume(returning: true) // Tài khoản iCloud có sẵn
                    case .noAccount:
                        continuation.resume(returning: false) // Không có tài khoản iCloud
                    case .restricted:
                        continuation.resume(returning: false) // Tài khoản bị hạn chế
                    case .couldNotDetermine:
                        continuation.resume(returning: false) // Không thể xác định trạng thái
                    default:
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
}
