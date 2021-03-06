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

class ViewModel: ObservableObject {

    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    let signUpAndScheduleURL = "https://mychart-openscheduling.et1130.epichosted.com/MyChart/SignupAndSchedule/EmbeddedSchedule?id=51585&dept=10554002&vt=1788&utm_medium=email&utm_source=health_focus&utm_campaign=2-22_vaccine_appointments"
    
    @Published var appointmentsAvailable = false
    @Published var checkingForAppointments = false
    
    @Published var shouldCheckForAppointments = false
    @Published var showAppointmentsPage = false
    
    var subscriptions = Set<AnyCancellable>()
    
    var timer = Timer()
    let delay = 2.0
    
    init() {
        $appointmentsAvailable.sink { available in
            if available {
                self.notificationFeedbackGenerator.notificationOccurred(.success)
            }
        }
        .store(in: &subscriptions)
    }
    
    func checkForAppointments() {
        checkingForAppointments = true
        AF.request(signUpAndScheduleURL).responseString { response in
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
                "Referer": "https://mychart-openscheduling.et1130.epichosted.com/MyChart/SignupAndSchedule/EmbeddedSchedule?id=51585&dept=10554002&vt=1788&utm_medium=email&utm_source=health_focus&utm_campaign=2-22_vaccine_appointments",
                "Accept-Language": "en-US,en;q=0.9,ja;q=0.8",
            ]
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            let today = dateFormatterGet.string(from: Date())
            let future = dateFormatterGet.string(from: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date())
            
            let data = [
                "id": "51585",
                "vt": "1788",
                "dept": "10554002",
                "view": "grouped",
                "start":  today,
                "end": future,
                "filters": "{\"Providers\":{\"51585\":true},\"Departments\":{\"10554002\":true},\"DaysOfWeek\":{\"0\":true,\"1\":true,\"2\":true,\"3\":true,\"4\":true,\"5\":true,\"6\":true},\"TimesOfDay\":\"both\"}"
            ]
            
            AF.request(universityApiUrl, method: .post, parameters: data, headers: headers).responseJSON { response in
                let dictionary = response.value as! NSDictionary
                print(dictionary)
                if let appointments = dictionary["ByDateThenProviderCollated"] as? NSDictionary, appointments.count > 0 {
                    self.appointmentsAvailable = true
                } else {
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
        timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(delayedAction), userInfo: nil, repeats: false)
    }
    
    // function to be called after the delay
    @objc func delayedAction() {
        checkForAppointments()
    }
    
    func startChecking() {
        shouldCheckForAppointments = true
        checkForAppointments()
    }
    
    func stopChecking() {
        shouldCheckForAppointments = false
        timer.invalidate()
    }
    
    func deleteCookies() {
        AF.session.configuration.httpCookieStorage?.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
    }
}
