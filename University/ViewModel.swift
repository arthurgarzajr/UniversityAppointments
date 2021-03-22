//
//  ViewModel.swift
//  University
//
//  Created by Arthur Garza on 3/4/21.
//

import Foundation
import Alamofire
import SwiftSoup
import Combine
import AVKit

class ViewModel: ObservableObject {

    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    let signUpAndScheduleURL = Constants.signUpAndScheduleURL
    
    @Published var appointmentsAvailable = false
    @Published var appointmentsAvailableMessage = ""
    
    @Published var checkingForAppointments = false
    @Published var pausedCheckingForAppointments = false
    
    @Published var shouldCheckForAppointments = false
    @Published var showAppointmentsPage = false
    @Published var showAutofillPage = false
    
    var subscriptions = Set<AnyCancellable>()
    var checkingForAppointmentsSubscriber: AnyCancellable?
    
    var appointmentSoundEffect: AVAudioPlayer?
    
    var timer = Timer()
    
    var signUpAndScheduleRequest: DataRequest?
    var apiRequest: DataRequest?
    @Published var delay: Int = 0
    
    init() {
        $appointmentsAvailable.sink { available in
            if available {
                self.notificationFeedbackGenerator.notificationOccurred(.success)
                self.playAppointmentsDetectedSound()
            }
        }
        .store(in: &subscriptions)
        
        $showAppointmentsPage.sink { showing in
            if self.checkingForAppointments {
                self.pausedCheckingForAppointments = true
            }
            
            if !showing {
                self.clearCookies(for: self.signUpAndScheduleURL)
            }
        }
        .store(in: &subscriptions)
        

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.ambient, mode: .spokenAudio, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            
        }
    }
    
    func main() {
        // Check if we should start checking for appointments
        shouldCheckForAppointments = UserDefaults.standard.bool(forKey: "shouldCheckForAppointments")
        if shouldCheckForAppointments {
            checkForAppointments()
        }
    }
    
    func checkForAppointments() {
        guard !showAppointmentsPage else {
            return
        }
        
        checkingForAppointments = true
        
        clearCookies(for: self.signUpAndScheduleURL)
        
        signUpAndScheduleRequest = AF.request(signUpAndScheduleURL).responseString { response in
            guard let doc: Document = try? SwiftSoup.parse(response.value ?? ""), let urlResponse = response.response else {
                print("Error")
                self.checkingForAppointments = false
                return
            }
            
            let requestVerificationToken = self.getRequestVerificationToken(document: doc)
            let cookies = self.getCookies(urlResponse: urlResponse)
            let universityApiUrl = self.getUniversityAPIURL()
            
            // Pass along the cookies from this request to the next
            AF.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: universityApiUrl), mainDocumentURL: nil)
            
            // Headers
            let headers: HTTPHeaders = [
                "Connection": "keep-alive",
                "sec-ch-ua": "\"Google Chrome\";v=\"87\", \" Not;A Brand\";v=\"99\", \"Chromium\";v=\"87\"",
                "Accept": "*/*",
                "X-Requested-With": "XMLHttpRequest",
                "sec-ch-ua-mobile": "?0",
                "__RequestVerificationToken": requestVerificationToken,
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36",
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                "Origin": "https://mychart-openscheduling.et1130.epichosted.com",
                "Sec-Fetch-Site": "same-origin",
                "Sec-Fetch-Mode": "cors",
                "Sec-Fetch-Dest": "empty",
                "Referer": "https://mychart-openscheduling.et1130.epichosted.com/MyChart/SignupAndSchedule/EmbeddedSchedule?id=51748&dept=10554003&vt=1788&view=grouped&utm_medium=email&utm_source=health_focus&utm_campaign=2-22_vaccine_appointments",
                "Accept-Language": "en-US,en;q=0.9,ja;q=0.8",
            ]
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            let today = dateFormatterGet.string(from: Date())
            let future = dateFormatterGet.string(from: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date())
            
            let data = [
                "id": "51748",
                "vt": "1788",
                "dept": "10554003",
                "view": "grouped",
                "start":  today,
                "end": future,
                "filters": "{\"Providers\":{\"51748\":true},\"Departments\":{\"10554003\":true},\"DaysOfWeek\":{\"0\":true,\"1\":true,\"2\":true,\"3\":true,\"4\":true,\"5\":true,\"6\":true},\"TimesOfDay\":\"both\"}"
            ]
            
            self.apiRequest = AF.request(universityApiUrl, method: .post, parameters: data, headers: headers).responseJSON { response in
                guard let dictionary = response.value as? NSDictionary else {
                    self.appointmentsAvailable = false
                    if self.shouldCheckForAppointments {
                        self.startDelayTimer()
                    }
                    return
                }
                let appointmentCount = (dictionary.description.components(separatedBy: "ArrivalTimeISO").count - 1) / 2
                if appointmentCount > 0 {
                    print("Available")
                    
                    self.appointmentsAvailable = true
                    self.showAppointmentsPage = true
                    
                    self.appointmentsAvailableMessage = appointmentCount == 1 ? "1 appointment available" : String(appointmentCount) + " appointments available"

                } else {
                    print("Not Available")
                    self.appointmentsAvailableMessage = ""
                    self.appointmentsAvailable = false
                }
                
                self.checkingForAppointments = false
                
                if self.shouldCheckForAppointments {
                    self.startDelayTimer()
                }
            }
        }
    }
    
    func getUniversityAPIURL() -> String {
        let random = Double.random(in: 0..<1)
        return  "https://mychart-openscheduling.et1130.epichosted.com/MyChart/OpenScheduling/OpenScheduling/GetOpeningsForProvider?noCache=\(random)"
    }
    
    func getRequestVerificationToken(document: Document) -> String {
        var token = ""
        do {
            let elements = try document.select("[name=__RequestVerificationToken]")
            let transaction_id = elements.get(0)
            token = try transaction_id.val()
        } catch {
            self.checkingForAppointments = false
        }
        return token
    }
    
    func getCookies(urlResponse: HTTPURLResponse) -> [HTTPCookie] {
        var cookies = [HTTPCookie]()
        if let headerFields = urlResponse.allHeaderFields as? [String: String], let URL = urlResponse.url {
            cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
        }
        return cookies
    }
    
    func startDelayTimer() {
        
        // cancel the timer in case the button is tapped multiple times
        timer.invalidate()
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(delayedAction), userInfo: nil, repeats: false)
    }
    // function to be called after the delay
    @objc func delayedAction() {
        checkForAppointments()
    }
    
    func waitForCheckerToStopBeforeShowingWebpage() {
        cancelRequests()
        if checkingForAppointments {
            checkingForAppointmentsSubscriber = $checkingForAppointments.sink { checkingForAppointments in
                if !checkingForAppointments {
                    self.showAppointmentsPage = true
                    self.checkingForAppointmentsSubscriber?.cancel()
                }
            }
        } else {
            self.showAppointmentsPage = true
        }
    }
    
    func startChecking() {
        shouldCheckForAppointments = true
        UserDefaults.standard.set(true, forKey: "shouldCheckForAppointments")
        main()
    }
    
    func stopChecking() {
        shouldCheckForAppointments = false
        pausedCheckingForAppointments = false
        UserDefaults.standard.set(true, forKey: "shouldCheckForAppointments")
        timer.invalidate()
    }
    
    func cancelRequests() {
        apiRequest?.cancel()
        signUpAndScheduleRequest?.cancel()
    }
    
    func clearCookies(for urlString: String) {
        guard let url = URL(string: urlString), !showAppointmentsPage, !appointmentsAvailable else {
            return
        }
        
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies(for: url) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }
    }
    
    func webViewDismissed() {
        if pausedCheckingForAppointments {
            checkForAppointments()
        }
    }
    
    func playAppointmentsDetectedSound() {
        let path = Bundle.main.path(forResource: "me-too.caf", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            appointmentSoundEffect = try AVAudioPlayer(contentsOf: url)
            appointmentSoundEffect?.play()
        } catch {
            // couldn't load file :(
        }
    }
}
