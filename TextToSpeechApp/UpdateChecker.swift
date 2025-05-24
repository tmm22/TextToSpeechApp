import Foundation
import Combine
import AppKit

struct GitHubRelease: Codable {
    let tagName: String
    let name: String
    let body: String
    let publishedAt: String
    let htmlUrl: String
    let prerelease: Bool
    let draft: Bool
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case publishedAt = "published_at"
        case htmlUrl = "html_url"
        case prerelease
        case draft
    }
}

struct AppVersion {
    let major: Int
    let minor: Int
    let patch: Int
    
    init?(from string: String) {
        // Remove 'v' prefix if present
        let cleanString = string.hasPrefix("v") ? String(string.dropFirst()) : string
        let components = cleanString.split(separator: ".").compactMap { Int($0) }
        
        guard components.count >= 2 else { return nil }
        
        self.major = components[0]
        self.minor = components[1]
        self.patch = components.count > 2 ? components[2] : 0
    }
    
    var versionString: String {
        return "\(major).\(minor).\(patch)"
    }
    
    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }
    
    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

enum UpdateStatus {
    case checking
    case upToDate
    case updateAvailable(GitHubRelease)
    case error(String)
}

class UpdateChecker: ObservableObject {
    @Published var updateStatus: UpdateStatus = .upToDate
    @Published var isCheckingForUpdates = false
    @Published var lastCheckDate: Date?
    
    private let githubRepo = "tmm22/TextToSpeechApp"
    private let currentVersion: AppVersion
    private var cancellables = Set<AnyCancellable>()
    
    // User preferences
    @Published var automaticUpdateChecksEnabled: Bool {
        didSet {
            UserDefaults.standard.set(automaticUpdateChecksEnabled, forKey: "automaticUpdateChecksEnabled")
            if automaticUpdateChecksEnabled {
                scheduleAutomaticCheck()
            }
        }
    }
    
    init() {
        // Get current version from bundle
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "2.0.0"
        self.currentVersion = AppVersion(from: bundleVersion) ?? AppVersion(from: "2.0.0")!
        
        // Load user preference for automatic checks (default: true)
        self.automaticUpdateChecksEnabled = UserDefaults.standard.object(forKey: "automaticUpdateChecksEnabled") as? Bool ?? true
        
        // Load last check date
        if let lastCheckTimestamp = UserDefaults.standard.object(forKey: "lastUpdateCheckDate") as? TimeInterval {
            self.lastCheckDate = Date(timeIntervalSince1970: lastCheckTimestamp)
        }
        
        // Schedule automatic check if enabled
        if automaticUpdateChecksEnabled {
            scheduleAutomaticCheck()
        }
    }
    
    func checkForUpdates() {
        guard !isCheckingForUpdates else { return }
        
        isCheckingForUpdates = true
        updateStatus = .checking
        
        guard let url = URL(string: "https://api.github.com/repos/\(githubRepo)/releases/latest") else {
            updateStatus = .error("Invalid GitHub API URL")
            isCheckingForUpdates = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("TextToSpeechApp/\(currentVersion.versionString)", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GitHubRelease.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isCheckingForUpdates = false
                    
                    if case .failure(let error) = completion {
                        self?.updateStatus = .error("Failed to check for updates: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] release in
                    self?.handleReleaseResponse(release)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleReleaseResponse(_ release: GitHubRelease) {
        // Update last check date
        lastCheckDate = Date()
        UserDefaults.standard.set(lastCheckDate?.timeIntervalSince1970, forKey: "lastUpdateCheckDate")
        
        // Skip draft and prerelease versions
        guard !release.draft && !release.prerelease else {
            updateStatus = .upToDate
            return
        }
        
        // Parse the release version
        guard let releaseVersion = AppVersion(from: release.tagName) else {
            updateStatus = .error("Unable to parse release version: \(release.tagName)")
            return
        }
        
        // Compare versions
        if currentVersion < releaseVersion {
            updateStatus = .updateAvailable(release)
        } else {
            updateStatus = .upToDate
        }
    }
    
    private func scheduleAutomaticCheck() {
        // Check if we should perform an automatic check
        // Only check once per day to avoid rate limiting
        let shouldCheck: Bool
        
        if let lastCheck = lastCheckDate {
            let daysSinceLastCheck = Calendar.current.dateComponents([.day], from: lastCheck, to: Date()).day ?? 0
            shouldCheck = daysSinceLastCheck >= 1
        } else {
            shouldCheck = true
        }
        
        if shouldCheck {
            // Delay the check by a few seconds to avoid blocking app startup
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.checkForUpdates()
            }
        }
    }
    
    func openReleaseURL(_ release: GitHubRelease) {
        guard let url = URL(string: release.htmlUrl) else { return }
        NSWorkspace.shared.open(url)
    }
    
    var currentVersionString: String {
        return currentVersion.versionString
    }
    
    var shouldShowUpdateNotification: Bool {
        if case .updateAvailable = updateStatus {
            return true
        }
        return false
    }
}