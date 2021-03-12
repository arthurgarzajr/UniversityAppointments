//
//  WebView.swift
//  University
//
//  Created by Arthur Garza on 3/11/21.
//

import SwiftUI
import WebKit

struct WebViewUI: View {
    @ObservedObject var webViewStateModel: WebViewStateModel = WebViewStateModel()
    var url: String
    @State private var showingActionSheet = false
    
    var body: some View {
        
        NavigationView {
            LoadingView(isShowing: .constant(webViewStateModel.loading)) { //loading logic taken from https://stackoverflow.com/a/56496896/9838937
                //Add onNavigationAction if callback needed
                WebView(url: URL.init(string: url)!, webViewStateModel: self.webViewStateModel)
                
            }
            .actionSheet(isPresented: $showingActionSheet) {
                let actionSheet = ActionSheet(title: Text("Change background"), message: Text("Select a new color"), buttons: [
                    .default(Text("Arthur Garza")) {
                        webViewStateModel.autoFill(name: "Arthur Garza")
                        
                    },
                    .cancel()
                ])
                
                return actionSheet
            }
            .navigationBarTitle(Text(webViewStateModel.pageTitle), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button("Autofill") {
                                        self.showingActionSheet = true
                                    }
            )
            
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {
    
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    Text("Loading...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
                
            }
        }
    }
    
}

///// Implementaton
class WebViewStateModel: ObservableObject {
    @Published var pageTitle: String = "Web View"
    @Published var loading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var goBack: Bool = false
    
    let webView = WKWebView()
    
    func autoFill(name: String) {
        let firstName = "FirstName"
        let arthur = "Arthur"
        
        let enableAutocomplete = "document.getElementById('FirstName').value = 'Arthur'"
        _ = "document.getElementById('\(firstName)\').value = '\(arthur)'"
        webView.evaluateJavaScript(enableAutocomplete) { result, error in
            
            print(error)
        }
        
    }
}

struct WebView: View {
    enum NavigationAction {
        case decidePolicy(WKNavigationAction,  (WKNavigationActionPolicy) -> Void) //mendetory
        case didRecieveAuthChallange(URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) //mendetory
        case didStartProvisionalNavigation(WKNavigation)
        case didReceiveServerRedirectForProvisionalNavigation(WKNavigation)
        case didCommit(WKNavigation)
        case didFinish(WKNavigation)
        case didFailProvisionalNavigation(WKNavigation,Error)
        case didFail(WKNavigation,Error)
    }
    
    @ObservedObject var webViewStateModel: WebViewStateModel
    
    private var actionDelegate: ((_ navigationAction: WebView.NavigationAction) -> Void)?
    
    
    let uRLRequest: URLRequest
    
    
    var body: some View {
        
        WebViewWrapper(webViewStateModel: webViewStateModel,
                       action: actionDelegate,
                       request: uRLRequest)
    }
    /*
     if passed onNavigationAction it is mendetory to complete URLAuthenticationChallenge and decidePolicyFor callbacks
     */
    init(uRLRequest: URLRequest, webViewStateModel: WebViewStateModel, onNavigationAction: ((_ navigationAction: WebView.NavigationAction) -> Void)?) {
        self.uRLRequest = uRLRequest
        self.webViewStateModel = webViewStateModel
        self.actionDelegate = onNavigationAction
    }
    
    init(url: URL, webViewStateModel: WebViewStateModel, onNavigationAction: ((_ navigationAction: WebView.NavigationAction) -> Void)? = nil) {
        self.init(uRLRequest: URLRequest(url: url),
                  webViewStateModel: webViewStateModel,
                  onNavigationAction: onNavigationAction)
    }
}

/*
 A weird case: if you change WebViewWrapper to struct cahnge in WebViewStateModel will never call updateUIView
 */

final class WebViewWrapper : UIViewRepresentable {
    @ObservedObject var webViewStateModel: WebViewStateModel
    let action: ((_ navigationAction: WebView.NavigationAction) -> Void)?
    
    let request: URLRequest
    var webView: WKWebView
    
    init(webViewStateModel: WebViewStateModel,
         action: ((_ navigationAction: WebView.NavigationAction) -> Void)?,
         request: URLRequest) {
        self.webView = webViewStateModel.webView
        
        self.action = action
        self.request = request
        self.webViewStateModel = webViewStateModel
    }
    
    
    func makeUIView(context: Context) -> WKWebView  {
        webView.navigationDelegate = context.coordinator
        webView.load(request)
//        self.webView.loadHTMLString("""
//            <!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
//            <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en" dir="ltr" class="embedded">
//            <head>
//            <title>MyChart - Schedule an Appointment</title>
//            <meta http-equiv="content-type" content="text/html; charset=utf-8" />
//            <meta http-equiv="X-UA-Compatible" content="IE=edge" />
//            <link href="/MyChart/favicon.ico" rel="shortcut icon" />
//            <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
//            <link type="text/css" rel="stylesheet" media="All" href="/MyChart/en-us/styles/common.css?updateDt=1614591991" />
//            <link type="text/css" rel="stylesheet" media="All" href="/MyChart/en-us/styles/colors.css?updateDt=1614591991" />
//            <link type="text/css" rel="stylesheet" media="All" href="/MyChart/en-us/styles/themes.css?updateDt=1614591992" />
//            <link href="/MyChart/Content/EpicWP.css" rel="stylesheet" type="text/css" />
//            <link type="text/css" rel="stylesheet" media="Print" href="/MyChart/en-us/styles/print.css?updateDt=1614591992" />
//
//
//            </head>
//            <body class="embedded isPrelogin" onload="$$WP.CommunityUtilities.checkIfCommunityLinksAvailable();">
//
//            <div id="jsdisabled" class="overlay"><div class="lightbox_overlay"></div><div class="jsdisabled"><p><span class="clearlabel">Error: </span>Please enable JavaScript in your browser before using this site.</p></div><script type="text/javascript">document.getElementById('jsdisabled').style.display = 'none';</script></div>
//            <div id="wrap">
//            <div class='hidden' id='__CSRFContainer'><input name="__RequestVerificationToken" type="hidden" value="P3hG0Kra2emOtkIw35Q3KmVxx6uEzLvvzauqRqjvdcopG0gSs-VEF8pP8N62WAFkSSVpQSw9Vi6-upMgx9n1hKJhbfI1" /></div>
//
//            <div id="lightbox" class="lb_content jqHidden"></div>
//            <div id="lightbox_overlay" class="lightbox_overlay lb_overlay jqHidden" onclick="$$WP.Utilities.HideLightbox(this);"></div>
//            <div id="content">
//            <div id="main">
//
//
//
//
//
//
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_setOfStepsContainer" class="setOfStepsContainer">
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_slider" class="slider extraWide">
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_embeddedContainer" class="stepContainer">
//
//
//
//
//
//
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_OpeningsContainer" class="openingsContainer hidden">
//
//
//
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_OpeningsControls" class="openingsControls hidden">
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_filterContainer" class="filterControlContainer"></div>
//            </div>
//
//            <div class="scrollTableWrapper">
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_OpeningsData" class="openingsData"></div>
//            </div>
//
//
//            </div>
//
//
//
//
//            <div role="alert" class="ajaxspinner defaultajaxoverlay hidden"><div class="loadingmessage">Loading...<div class="loadingHeart"></div></div></div>
//
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_coreScripts" class="hidden">
//
//                    <script type='text/javascript'>
//                        if (typeof WP === 'undefined') {
//                            WP = {};
//                        }
//                        WP.myPath = '/MyChart/';
//                    </script>
//            <script src="/MyChart/scripts/external/jquery-2.2.2.min.js?updateDt=1504912084" type="text/javascript"></script>
//            <script src="/MyChart/scripts/utilities/jqwrappers.min.js?updateDt=1533203510" type="text/javascript"></script>
//            <script src="/MyChart/scripts/utilities/jqueryextensions.min.js?updateDt=1533203510" type="text/javascript"></script>
//            <script src="/MyChart/scripts/external/handlebars.runtime.min.js?updateDt=1517460258" type="text/javascript"></script>
//            <script src="/MyChart/bundles/core-1-pre?v=kZvvT_rJfc-CDzmE8u-WSkjv9nOOpsl9_eUlcs40iAg1"></script>
//
//            <script src="/MyChart/localization/formats?lang=en-us&updateDt=-1311755705" type="text/javascript"></script>
//            <script src="/MyChart/cookie/webserversettings?updateDt=-1311755705" type="text/javascript"></script>
//            <script src="/MyChart/bundles/core-2-en-US?v=Rs9o5FHqD91CvsEPq2EbxzYlZRpP0em0VOnZyIqo5uo1"></script>
//
//            <script src="/MyChart/mnemonics?updateDt=-1311755705" type="text/javascript"></script>
//            <script src="/MyChart/bundles/core-3-en-US?v=QKVKApS7-CKl4c7xtPQQ3ernKA0QBLJ8kA9BiutYyFw1"></script>
//
//            <script type="text/javascript">
//            $$WP.I18N.AllLocales = $$WP.I18N.Locale.createModelCollection();
//            $$WP.I18N.Locale.convertRawLocales({"en-US":{"IsDBLocale":false,"Direction":1,"Language":"EN","ForceMetricUnits":false,"DateSeparator":"/","TimeSeparator":":","Is24HourTime":false,"FirstDayOfTheWeek":1,"DecimalSeparator":".","GroupSeparator":",","DecimalPlaces":"2","GroupSize":"3","NegativePattern":"-n","CurrencySymbol":"$","CurrencyCode":"USD","CurrencyDecimalPlaces":"2","CurrencyGroupSize":"3","CurrencyPositivePattern":"$n","CurrencyNegativePattern":"-$n","PercentSymbol":"%","ListSeparator":",","ListSpaces":1},"es-US":{"IsDBLocale":false,"Direction":1,"Language":"ES","ForceMetricUnits":false,"DateSeparator":"/","TimeSeparator":":","Is24HourTime":false,"FirstDayOfTheWeek":1,"DecimalSeparator":".","GroupSeparator":",","DecimalPlaces":"2","GroupSize":"3","NegativePattern":"-n","CurrencySymbol":"$","CurrencyCode":"USD","CurrencyDecimalPlaces":"2","CurrencyGroupSize":"3","CurrencyPositivePattern":"$n","CurrencyNegativePattern":"-$n","PercentSymbol":"%","ListSeparator":",","ListSpaces":1}}, $$WP.I18N.AllLocales);
//            var tmp = $$WP.I18N.AllLocales.getFromIndex('Identifier', MyChartLocale);
//            if (tmp === null) { $$WP.Debug.logError('Unable to load locale "' + MyChartLocale + '" from $$WP.I18N.AllLocales.'); tmp = new $$WP.I18N.Locale(); }
//            $$WP.CurrentLocale = tmp.toRawObject();
//            </script>
//
//            <script src="/MyChart/bundles/core-5-en-US?v=SfzC9q7nQ_mRdxIa7pPWSEyLH0yLVQQtcgfjO2_zwKo1"></script>
//
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_scripts" class="hidden">
//
//            <script src="/MyChart/areas/openscheduling/scripts/controllers/scheduleopeningscontroller.min.js?updateDt=1612888670" type="text/javascript"></script>
//            <script src="/MyChart/scripts/controllers/logincontroller.min.js?updateDt=1612888662" type="text/javascript"></script>
//            <script src="/MyChart/scripts/controllers/signupcontroller.min.js?updateDt=1612888662" type="text/javascript"></script>
//            <script src="/MyChart/scripts/controllers/loginsignupcontroller.min.js?updateDt=1612888662" type="text/javascript"></script>
//            <script src="/MyChart/areas/openscheduling/templates/openingsgrouped.tmpl.js?updateDt=1588277558" type="text/javascript"></script>    <script src="/MyChart/areas/openscheduling/templates/openingsfilters.tmpl.js?updateDt=1579049460" type="text/javascript"></script>
//            <script src="/MyChart/areas/openscheduling/templates/departmentfilter.tmpl.js?updateDt=1517460258" type="text/javascript"></script>
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_templates" class="hidden">
//
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_OpeningsNoData" data-template-children-only="true">
//            <div class="errormessage">
//                <span class="nodata"><span class="clearlabel">Error: </span><span>Sorry, we couldn't find any open appointments.</span></span>
//            </div>
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_OpeningsAllFiltered" data-template-children-only="true">
//            <div class="errormessage">
//                <span class="nodata">Sorry, we couldn't find any locations near you.</span>
//                <span>
//                    <a href="#" id="__#ID__showall" class="button autowidth">Show All Locations</a>
//                </span>
//            </div>
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_providerInfoContainer" class="provinfocontainer" style="display: none;" data-template-no-id="true">
//            __ProvInfo__
//            </div>
//            <ul id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_peopleFilterColumn">
//            <li data-template-type="collection" class="nohover" data-template-id="p">
//                <input type="checkbox" id="__#ID__prov" class="prettycheck filter personFilter" checked="checked" data-filter-group="people" value="__ID__" />
//                <label for="__#ID__prov">__DisplayName__</label>
//            </li>
//            </ul>
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_resources" class="hidden">
//
//            <div data-rsrc-id="findSlotsFromDateLabel">Find available appointments starting on</div>
//
//            <div data-rsrc-id="personFilterLabel">Person</div>
//            <div data-rsrc-id="peopleFilterButtonAllText">All</div>
//            <div data-rsrc-id="somePeopleFilterButtonText">@MYCHART@NUMPEOPLESELECTED@ of @MYCHART@TOTALPEOPLE@</div>
//            <div data-rsrc-id="peopleFilterSelectAllText">Check All</div>
//            <div data-rsrc-id="peopleFilterSelectNoneText">Uncheck All</div>
//            <div data-rsrc-id="peopleFilterApplyText">Apply</div>
//
//            <div data-rsrc-id="locationFilterLabel">Location</div>
//            <div data-rsrc-id="locationFilterButtonAllText">All</div>
//            <div data-rsrc-id="someLocationsFilterButtonText">@MYCHART@NUMLOCATIONSSELECTED@ of @MYCHART@TOTALLOCATIONS@</div>
//            <div data-rsrc-id="locationFilterSelectAllText">Check All</div>
//            <div data-rsrc-id="locationFilterSelectNoneText">Uncheck All</div>
//            <div data-rsrc-id="locationFilterApplyText">Apply</div>
//
//            <div data-rsrc-id="locationFilterDepartmentDistance">@MYCHART@DEPARTMENTDISTANCE@ miles</div>
//            <div data-rsrc-id="locationFilterDepartmentDistanceOverMaximum">Over 150 miles</div>
//            <div data-rsrc-id="locationFilterDepartmentMaximumDistance" data-rsrc-val="150"></div>
//            <div data-rsrc-id="locationFilterShowMoreButtonLabel">Load more</div>
//
//            <div data-rsrc-id="dateFilterLabel">Start search on</div>
//            <div data-rsrc-id="dateTimeFilterLabel">Day / Time</div>
//            <div data-rsrc-id="dateTimeFilterButtonAllText">All</div>
//            <div data-rsrc-id="dayOfWeekLegend">day of week</div>
//            <div data-rsrc-id="timeOfDayLegend">time of day</div>
//            <div data-rsrc-id="timeFilterAMLabel">AM</div>
//            <div data-rsrc-id="timeFilterPMLabel">PM</div>
//            <div data-rsrc-id="timeFilterAllTimesLabel">Both</div>
//            <div data-rsrc-id="dateTimeFilterApplyText">Apply</div>
//
//            <div data-rsrc-id="timeFilterButtonAMText">AM</div>
//            <div data-rsrc-id="timeFilterButtonPMText">PM</div>
//            <div data-rsrc-id="timeFilterButtonAMWithDaysText">AM</div>
//            <div data-rsrc-id="timeFilterButtonPMWithDaysText">PM</div>
//            <div data-rsrc-id="dayFilterSeparator">,</div>
//            <div data-rsrc-id="dateFilterButtonText">@MYCHART@DAYSONLY@</div>
//            <div data-rsrc-id="dateTimeFilterButtonText">@MYCHART@DAYS@ - @MYCHART@TIMES@</div>
//
//
//            <div data-rsrc-id="dayName_0">Sunday</div>
//            <div data-rsrc-id="dayAbbreviation_0">Sun</div>
//            <div data-rsrc-id="dayName_1">Monday</div>
//            <div data-rsrc-id="dayAbbreviation_1">Mon</div>
//            <div data-rsrc-id="dayName_2">Tuesday</div>
//            <div data-rsrc-id="dayAbbreviation_2">Tue</div>
//            <div data-rsrc-id="dayName_3">Wednesday</div>
//            <div data-rsrc-id="dayAbbreviation_3">Wed</div>
//            <div data-rsrc-id="dayName_4">Thursday</div>
//            <div data-rsrc-id="dayAbbreviation_4">Thu</div>
//            <div data-rsrc-id="dayName_5">Friday</div>
//            <div data-rsrc-id="dayAbbreviation_5">Fri</div>
//            <div data-rsrc-id="dayName_6">Saturday</div>
//            <div data-rsrc-id="dayAbbreviation_6">Sat</div>
//            <div data-rsrc-id="moreSlotsLabel_1">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_2">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_3">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_4">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_5">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_6">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_7">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_8">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_9">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_10">more...</div>
//            <div data-rsrc-id="moreSlotsLabel_11">more...</div>
//
//            <div data-rsrc-id="numberOfDepartmentsOnFirstLoad" data-rsrc-val="6"></div>
//            <div data-rsrc-id="distanceToAlwaysIncludeDepartments" data-rsrc-val="10"></div>
//            <div data-rsrc-id="distanceToNeverIncludeDepartments" data-rsrc-val="50"></div>
//            <div data-rsrc-id="MinDaysForFutureSearch" data-rsrc-val="0"></div>
//            <div data-rsrc-id="MaxDaysForFutureSearch" data-rsrc-val="90"></div>
//            <div data-rsrc-id="isReservationEnabled" data-rsrc-val="True"></div>
//            <div data-rsrc-id="canShowVisitDuration" data-rsrc-val="True"></div>
//            <div data-rsrc-id="isDemoMode" data-rsrc-val="False"></div>
//            <div data-rsrc-id="providerUrlTitleText">See more information about @MYCHART@PROVIDERURLTITLETEXTPROVIDERNAME@.</div>
//            <div data-rsrc-id="providerPhotoAltText">Photo of @MYCHART@PROVIDERPHOTOALTTEXTPROVIDERNAME@.</div>
//            <div data-rsrc-id="accessibleSlot">@MYCHART@ACCESSIBLESLOTTIME@<span class="clearlabel"> on @MYCHART@ACCESSIBLESLOTDATE@ in @MYCHART@ACCESSIBLESLOTDEPARTMENT@ with @MYCHART@ACCESSIBLESLOTPROVIDER@.</span></div>
//            <div data-rsrc-id="expandSlotsLabel">more...</div>
//            <div data-rsrc-id="collapseSlotsLabel">less...</div>
//
//            <div data-rsrc-id="rowDateLabel">on</div>
//            <div data-rsrc-id="navigateStepFourLink">Confirm and Schedule</div>
//
//            <div data-rsrc-id="defaultPhotoUrl">/MyChart/Content/images/provider.png</div>
//            <div data-rsrc-id="openingsUrl">/MyChart/OpenScheduling/OpenScheduling/GetScheduleDays</div>
//            <div data-rsrc-id="scheduleUrl">/MyChart/OpenScheduling/SignupAndSchedule/ScheduleAppointment</div>
//            <div data-rsrc-id="errorUrl">/MyChart/Home/OpenSchedulingError</div>
//            <div data-rsrc-id="locationSearchUrl">/MyChart/OpenScheduling/OpenScheduling/GetLocationSearchCoordinates</div>
//            <div data-rsrc-id="arrivalTimeLabel">Arrive by @MYCHART@ARRIVALTIME@</div>
//            <div data-rsrc-id="appointmentTimeLabel">Starts at @MYCHART@APPOINTMENTTIME@</div>
//            <div data-rsrc-id="durationString">(@MYCHART@DURATION@ minutes)</div>
//            <div data-rsrc-id="slotSelectFailMessage">That time is no longer available due to high demand.</div>
//            <div data-rsrc-id="reservationExpirationBlurb">This time slot is reserved for you until @MYCHART@RESERVATIONEXPIRATIONTIME@. Please complete scheduling by then.</div>
//            <div data-rsrc-id="refreshSlotsButtonCaption">Pick a new time</div>
//            <div data-rsrc-id="slotSelectFailTitle">Time unavailable</div>
//
//            <div data-rsrc-id="HighDemandRetryButtonCaption">Retry</div>
//            <div data-rsrc-id="HighDemandCloseButtonCaption">Close</div>
//            <div data-rsrc-id="HighDemandFirstLoadDescription">We are experiencing high demand right now.</div>
//            <div data-rsrc-id="HighDemandFirstLoadInstructions">Please check back in a bit.</div>
//            <div data-rsrc-id="HighDemandSubsequentLoadDescription">We could not load additional times due to very high demand.</div>
//            <div data-rsrc-id="HighDemandSubsequentLoadInstructions">Continue with one of the times listed or check back in a bit.</div>
//
//            <div data-rsrc-id="_openingsUrl">/MyChart/OpenScheduling/OpenScheduling/GetOpeningsForProvider</div>
//            <div data-rsrc-id="_scheduleUrl">/MyChart/OpenScheduling/SignupAndSchedule/ScheduleAppointment</div>
//                <div data-rsrc-id="_template" data-rsrc-val="grouped"></div>
//
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_authentication" class="hidden">
//
//            </div>
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_detailsContainer" class="slotDetailsContainer stepContainer offscreen scrollable">
//            <h2>Is this correct?</h2>
//
//
//
//
//            <div class="slotDetailsContainer" id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_slotDetailsContainer" tabindex="-1">
//            <div class="card">
//
//
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_slotDetails" class="jqHidden"></div>
//
//            <div class="comments">
//                <div class="ghostInput">
//                    <label for="Comments">Reason for Visit</label>
//                    <textarea autocomplete="off" cols="20" id="Comments" name="Comments" rows="2">
//            </textarea>
//                </div>
//                <div class="field-validation-valid comments-maxlength"><span class="clearlabel">Error: </span><span>Cannot exceed 250 characters.</span></div>
//                <span class=" helptext">Maximum 250 characters.</span>
//            </div>
//
//
//
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_apptDetailsControlsContainer" class="apptDetailsControlsContainer">
//            <a href="#" class="button prevMainStep">Back</a>
//            <a href="#" class="button scheduleaction completeworkflow">Continue</a>
//            </div>
//            </div>
//            </div>
//
//
//
//
//
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_coreScripts" class="hidden">
//
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_scripts" class="hidden">
//
//            <script src="/MyChart/areas/openscheduling/scripts/controllers/appointmentdetailscontroller.min.js?updateDt=1533203510" type="text/javascript"></script>
//            <script src="/MyChart/areas/openscheduling/templates/slotdetails.tmpl.js?updateDt=1612499198" type="text/javascript"></script>
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_templates" class="hidden">
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_resources" class="hidden">
//
//            <div data-rsrc-id="defaultPhotoUrl">/MyChart/Content/images/provider.png</div>
//
//            </div>
//            <div id="D6F73C26-7627-4948-95EA-2C630C25C5E9_scheduleOpenings_authentication" class="hidden">
//
//            </div>
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_loginSignupContainer" class="stepContainer offscreen scrollable">
//
//
//
//
//
//            <div id="484C8283-2719-4E8C-BE5C-666C65903FAD_loginSignup_loginSignupContainer" class="lb_content jqHidden loginSignupContainer" role="dialog" aria-modal="true">
//            <h1 class="header">You're Almost Done...</h1>
//
//
//
//
//
//
//
//
//
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_mychart-signup-container" class="signupContainer">
//
//            <div class="signupStepsContainer"><div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_slider" class="slider extraWide cardlist column_999 matchHeights">            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_landing" class="signupStep landing card">
//                <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_landing_content" class="content">
//
//
//
//
//
//
//
//
//            <div id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_mychart-login-container" class="loginContainer">
//            <form action="/MyChart/OpenScheduling/Authentication/Login" id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_Login" method="post" name="Login">            <div class="login">
//
//                    <div class="loginHeader">
//                        <h2 class="header">Have a MyChart account?</h2>
//
//            <p class="pretext">Use your MyChart credentials to schedule this appointment for yourself or someone you have access to.</p>                    </div>
//                    <div class="loginButton">
//                        <input class="button nextstep" type="button" id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_login" value="Log In" />
//                    </div>
//
//                <input data-val="true" data-val-required="The SupportsLogin field is required." id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_SupportsLogin" name="SupportsLogin" type="hidden" value="True" />
//
//
//            </div>
//            </form>    </div>
//
//
//
//
//
//            <div id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_coreScripts" class="hidden">
//
//
//            </div>
//            <div id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_scripts" class="hidden">
//
//
//
//            </div>
//            <div id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_templates" class="hidden">
//
//            </div>
//            <div id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_resources" class="hidden">
//
//            <div data-rsrc-id="AUTHENTICATION-FAILED"><span class="clearlabel">Error: </span>We could not verify your username and password. Please try again.</div>
//            <div data-rsrc-id="NON-PATIENT-LOGIN"><span class="clearlabel">Error: </span>You don't have a patient account with us. Please use the signup fields to the right to finish scheduling your appointment.</div>
//            <div data-rsrc-id="ID-REQUIRED"><span class="clearlabel">Error: </span>Username is required</div>
//            <div data-rsrc-id="PASSWORD-REQUIRED"><span class="clearlabel">Error: </span>Password is required</div>
//
//            <div data-rsrc-id="IsProviderContext">1</div>
//
//            </div>
//            <div id="DFA7477E-2068-4DCA-99B0-794909E5892F_login_authentication" class="hidden">
//
//            </div>
//                    <span class="orHolder header">OR</span>
//
//                    <div class="continueAsGuestContainer">
//                        <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_header" class="signupheader">
//                            <h2 class="header">Continue as a Guest</h2>
//                            <p class="pretext">Not a MyChart user? We'll need to collect more information about you or the patient you're scheduling for.</p>
//                        </div>
//
//                        <div class="navigation">
//                            <a href="#" id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_landing_prevMainStep" class="button prevMainStep">Back</a>
//                            <a href="#" id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_landing_nextstep" class="button nextstep">Continue</a>
//                        </div>
//
//                        <div class="signupheader">
//
//                        </div>
//                    </div>
//
//
//                </div>
//            </div>
//
//
//
//            <div class="signupsection">
//            <form action="/MyChart/OpenScheduling/SignupAndSchedule/Signup" autocomplete="off" id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_Signup" method="post" name="Signup" postsyncaction="SignupAndSchedule/ContinueSignup">            <div>
//            </div>
//
//
//
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_userinfo" class="signupStep userinfo card">
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_userinfo_clear-validation-summary-errors" class="clearlabel"></div>
//            <div class="cardline name heading partial">Patient Information</div>
//            <div class="cardline partial right required">Indicates a required field.</div>
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_userinfo_content" class="content">
//
//            <fieldset>
//            <legend class="clearlabel">Patient</legend>
//            <div class="column">
//                                <div class="ghostInput">
//                                    <label class="required" for="FirstName">First Name</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-50" data-val-length-max="50" id="FirstName" name="FirstName" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="FirstName" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label for="MiddleName">Middle Name</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-50" data-val-length-max="50" id="MiddleName" name="MiddleName" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="MiddleName" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label class="required" for="LastName">Last Name</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-50" data-val-length-max="50" id="LastName" name="LastName" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="LastName" data-valmsg-replace="true"></span>
//                                </div>
//                                <fieldset>
//                                    <legend class="required">Legal Sex</legend>
//                                    <div>
//
//                                            <span class="tbContainer">
//                                                <input class="clearradio" id="legalSex0" name="Gender" type="radio" value="1" />
//                                                <label for="legalSex0" class="togglebutton">Female</label>
//                                            </span>
//                                            <span class="tbContainer">
//                                                <input class="clearradio" id="legalSex1" name="Gender" type="radio" value="2" />
//                                                <label for="legalSex1" class="togglebutton">Male</label>
//                                            </span>
//                                            <span class="tbContainer">
//                                                <input class="clearradio" id="legalSex2" name="Gender" type="radio" value="3" />
//                                                <label for="legalSex2" class="togglebutton">Unknown</label>
//                                            </span>
//                                            <span class="tbContainer">
//                                                <input class="clearradio" id="legalSex3" name="Gender" type="radio" value="950" />
//                                                <label for="legalSex3" class="togglebutton">Nonbinary</label>
//                                            </span>
//                                            <span class="tbContainer">
//                                                <input class="clearradio" id="legalSex4" name="Gender" type="radio" value="951" />
//                                                <label for="legalSex4" class="togglebutton">X</label>
//                                            </span>
//                                    </div>
//                                </fieldset>
//            <span class="field-validation-valid" data-valmsg-for="Gender" data-valmsg-replace="true"></span>                                <span class="field-validation-valid" data-valmsg-for="legalSex0" data-valmsg-replace="true"></span>
//                                <div class="ghostInput">
//                                    <label class="required" for="DateOfBirthStr">Date of Birth</label>
//                                    <input autocomplete="off" id="DateOfBirthStr" name="DateOfBirthStr" placeholder="MM/DD/YYYY" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="DateOfBirthStr" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label for="NationalIdLast4">Social Security number (Last 4 Digits)</label>
//                                    <input class="text-box single-line" autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-4" data-val-length-max="4" id="NationalIdLast4" name="NationalIdLast4" type="password" value="" placeholder="NNNN" />
//                                    <span class="field-validation-valid" data-valmsg-for="NationalIdLast4" data-valmsg-replace="true"></span>
//                                </div>
//            </div><div class="column">                                <div class="ghostInput compact">
//                                    <label class="required" for="AddressLine1">Address</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-50" data-val-length-max="50" id="AddressLine1" name="AddressLine1" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="AddressLine1" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label class="clearlabel" for="AddressLine2">Address line 2</label>
//                                    <input class="text-box single-line" data-val="true" data-val-length="MAX-LENGTH-50" data-val-length-max="50" id="AddressLine2" name="AddressLine2" type="text" value="" />
//                                </div>
//                                <div class="ghostInput">
//                                    <label class="required" for="City">City</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-50" data-val-length-max="50" id="City" name="City" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="City" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label class="required" for="State">State</label>
//                                    <select data-val="true" data-val-number="The field State must be a number." data-val-required="The State field is required." id="State" name="State"><option selected="selected" value="-1"></option>
//            <option value="1">Alabama</option>
//            <option value="2">Alaska</option>
//            <option value="3">Arizona</option>
//            <option value="4">Arkansas</option>
//            <option value="5">California</option>
//            <option value="6">Colorado</option>
//            <option value="7">Connecticut</option>
//            <option value="8">Delaware</option>
//            <option value="9">District of Columbia</option>
//            <option value="10">Florida</option>
//            <option value="11">Georgia</option>
//            <option value="12">Hawaii</option>
//            <option value="13">Idaho</option>
//            <option value="14">Illinois</option>
//            <option value="15">Indiana</option>
//            <option value="16">Iowa</option>
//            <option value="17">Kansas</option>
//            <option value="18">Kentucky</option>
//            <option value="19">Louisiana</option>
//            <option value="20">Maine</option>
//            <option value="21">Maryland</option>
//            <option value="22">Massachusetts</option>
//            <option value="23">Michigan</option>
//            <option value="24">Minnesota</option>
//            <option value="25">Mississippi</option>
//            <option value="26">Missouri</option>
//            <option value="27">Montana</option>
//            <option value="28">Nebraska</option>
//            <option value="29">Nevada</option>
//            <option value="30">New Hampshire</option>
//            <option value="31">New Jersey</option>
//            <option value="32">New Mexico</option>
//            <option value="33">New York</option>
//            <option value="34">North Carolina</option>
//            <option value="35">North Dakota</option>
//            <option value="36">Ohio</option>
//            <option value="37">Oklahoma</option>
//            <option value="38">Oregon</option>
//            <option value="39">Pennsylvania</option>
//            <option value="40">Rhode Island</option>
//            <option value="41">South Carolina</option>
//            <option value="42">South Dakota</option>
//            <option value="43">Tennessee</option>
//            <option value="44">Texas</option>
//            <option value="45">Utah</option>
//            <option value="46">Vermont</option>
//            <option value="47">Virginia</option>
//            <option value="48">Washington</option>
//            <option value="49">West Virginia</option>
//            <option value="50">Wisconsin</option>
//            <option value="51">Wyoming</option>
//            <option value="52">Alberta</option>
//            <option value="53">British Columbia</option>
//            <option value="54">Manitoba</option>
//            <option value="55">Newfoundland</option>
//            <option value="56">New Brunswick</option>
//            <option value="57">Nova Scotia</option>
//            <option value="58">Ontario</option>
//            <option value="59">Prince Edward Island</option>
//            <option value="60">Quebec</option>
//            <option value="61">Saskatchewan</option>
//            <option value="62">Northwest Territories</option>
//            <option value="63">Yukon</option>
//            <option value="100">Aguascalientes</option>
//            <option value="101">Baja California</option>
//            <option value="102">Baja California Sur</option>
//            <option value="103">Campeche</option>
//            <option value="104">Chiapas</option>
//            <option value="105">Chihuahua</option>
//            <option value="106">Coahuila</option>
//            <option value="107">Colima</option>
//            <option value="108">Distrito Federal</option>
//            <option value="109">Durango</option>
//            <option value="110">Guanajuato</option>
//            <option value="111">Guerrero</option>
//            <option value="112">Hidalgo</option>
//            <option value="113">Jalisco</option>
//            <option value="114">M&#233;xico</option>
//            <option value="115">Michoac&#225;n</option>
//            <option value="116">Morelos</option>
//            <option value="117">Nayarit</option>
//            <option value="118">Nuevo Le&#243;n</option>
//            <option value="119">Oaxaca</option>
//            <option value="120">Puebla</option>
//            <option value="121">Quer&#233;taro</option>
//            <option value="122">Quintana Roo</option>
//            <option value="123">San Luis Potos&#237;</option>
//            <option value="124">Sinaloa</option>
//            <option value="125">Sonora</option>
//            <option value="126">Tabasco</option>
//            <option value="127">Tamaulipas</option>
//            <option value="128">Tlaxcala</option>
//            <option value="129">Veracruz</option>
//            <option value="130">Yucat&#225;n</option>
//            <option value="131">Zacatecas</option>
//            <option value="132">Nunavut</option>
//            <option value="133">American Samoa, South Pacific</option>
//            <option value="134">Marshall Islands</option>
//            <option value="135">Palau</option>
//            <option value="136">Federated States of Micronesia</option>
//            <option value="137">Guam</option>
//            <option value="138">Northern Mariana Islands</option>
//            <option value="139">Puerto Rico</option>
//            <option value="140">Virgin Islands</option>
//            <option value="141">Armed Forces Africa</option>
//            <option value="142">Armed Forces America</option>
//            <option value="143">Armed Forces Pacific</option>
//            </select>
//                                    <span class="field-validation-valid" data-valmsg-for="State" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label class="required" for="PostalCode">ZIP Code</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-20" data-val-length-max="20" id="PostalCode" name="PostalCode" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="PostalCode" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label for="HomePhone">Home Phone</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-18" data-val-length-max="18" id="HomePhone" name="HomePhone" placeholder="NNN-NNN-NNNN" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="HomePhone" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label for="WorkPhone">Work Phone</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-18" data-val-length-max="18" id="WorkPhone" name="WorkPhone" placeholder="NNN-NNN-NNNN" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="WorkPhone" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label for="MobilePhone">Mobile Phone</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-18" data-val-length-max="18" id="MobilePhone" name="MobilePhone" placeholder="NNN-NNN-NNNN" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="MobilePhone" data-valmsg-replace="true"></span>
//                                </div>
//                                <div class="ghostInput">
//                                    <label for="Email">Email</label>
//                                    <input autocomplete="off" data-val="true" data-val-length="MAX-LENGTH-50" data-val-length-max="50" id="Email" name="Email" type="text" value="" />
//                                    <span class="field-validation-valid" data-valmsg-for="Email" data-valmsg-replace="true"></span>
//                                </div>
//
//            </div>
//            </fieldset>
//            <div class="navigation">
//                <a href="#" id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_userinfo_prevstep" class="button prevstep">Back</a>
//
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_userinfo_validation-error" class="validation-summary-errors hidden"><span class="clearlabel">Error: </span><span>There are required fields that have not been completed.</span></div>
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_userinfo_validation-summary-errors" class="errorcontainer"></div>
//
//                <input type="button" id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_submit" class="button completeworkflow" value="Schedule It!"/>
//            </div>
//            </div>
//            </div>
//
//            <input data-val="true" data-val-required="The SupportsAccountCreation field is required." id="SupportsAccountCreation" name="SupportsAccountCreation" type="hidden" value="False" />
//            <input id="DuplicateResult" name="DuplicateResult" type="hidden" value="" />
//            <input id="DepartmentIdForPatientCreate" name="DepartmentIdForPatientCreate" type="hidden" value="" />
//            <input id="AppointmentProviderId" name="AppointmentProviderId" type="hidden" value="" />
//            <input id="AppointmentVisitTypeId" name="AppointmentVisitTypeId" type="hidden" value="" />
//            <input id="AppointmentTime" name="AppointmentTime" type="hidden" value="" />
//            <input id="AppointmentDate" name="AppointmentDate" type="hidden" value="" />
//            <input id="ReservationKey" name="ReservationKey" type="hidden" value="" />
//            <input id="SessionToken" name="SessionToken" type="hidden" value="" />
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_hidden-validation-summary-errors" class="hidden">
//                <div class="validation-summary-valid" data-valmsg-summary="true"><ul><li style="display:none"></li>
//            </ul></div>
//                <span class="field-validation-valid" data-form-valmsg-for="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_Signup"></span>
//            </div>
//            </form>    </div>
//
//            </div></div>
//            <div class="navigation">
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_landing_stepindicator" class="stepindicator hidden disabled"><span class="clearlabel">Log in to MyChart or continue as a guest</span><span class="clearlabel status" data-active="Active" data-inactive="Inactive" data-disabled="Disabled"></span><span class="clearlabel hidden validation">Has error</span></div>
//
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_userinfo_stepindicator" class="stepindicator hidden disabled"><span class="clearlabel">Patient information</span><span class="clearlabel status" data-active="Active" data-inactive="Inactive" data-disabled="Disabled"></span><span class="clearlabel hidden validation">Has error</span></div>
//
//
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_credentials_stepindicator" class="stepindicator hidden disabled"><span class="clearlabel">Verification step</span><span class="clearlabel status" data-active="Active" data-inactive="Inactive" data-disabled="Disabled"></span><span class="clearlabel hidden validation">Has error</span></div>
//            </div>
//            </div>
//
//
//
//
//
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_coreScripts" class="hidden">
//
//
//            </div>
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_scripts" class="hidden">
//
//
//
//            </div>
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_templates" class="hidden">
//
//            </div>
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_resources" class="hidden">
//
//            <div data-rsrc-id="alreadyActive">It looks like you have an active MyChart account. We've sent you a reminder of your login ID. Please log into the system.</div>
//            <div data-rsrc-id="inactiveAccount">It looks like you have a MyChart account, but it is inactive. Go ahead and complete this process. Call us about reactivating your MyChart access.</div>
//            <div data-rsrc-id="checkingUsernameMsg">Checking availability...</div>
//            <div data-rsrc-id="userNameTakenMsg"><span class="clearlabel">Error: </span>That username is not available</div>
//            <div data-rsrc-id="requiredLabel">(required)</div>
//            <div data-rsrc-id="VALIDATION-ERROR">Please correct the errors and try again.</div>
//            <div data-rsrc-id="FIRSTNAME-REQUIRED"><span class="clearlabel">Error: </span>First name is required.</div>
//            <div data-rsrc-id="MIDDLENAME-REQUIRED"><span class="clearlabel">Error: </span>Middle name is required.</div>
//            <div data-rsrc-id="LASTNAME-REQUIRED"><span class="clearlabel">Error: </span>Last name is required.</div>
//            <div data-rsrc-id="NAME-INVALID"><span class="clearlabel">Error: </span>Name contains invalid characters.</div>
//            <div data-rsrc-id="LAST-NAME-FROM-SPOUSE-REQUIRED"><span class="clearlabel">Error: </span>Spouse's last name is required.</div>
//            <div data-rsrc-id="SPOUSE-LAST-NAME-FIRST-REQUIRED"><span class="clearlabel">Error: </span>Spouse's last name first is required.</div>
//            <div data-rsrc-id="LAST-NAME-PREFIX-REQUIRED"><span class="clearlabel">Error: </span>Last name prefix is required.</div>
//            <div data-rsrc-id="SPOUSE-LAST-NAME-PREFIX-REQUIRED"><span class="clearlabel">Error: </span>Spouse's last name prefix is required.</div>
//            <div data-rsrc-id="SUFFIX-REQUIRED"><span class="clearlabel">Error: </span>Name suffix is required.</div>
//            <div data-rsrc-id="GIVEN-NAME-INITIALS-REQUIRED"><span class="clearlabel">Error: </span>Given name initials are required.</div>
//            <div data-rsrc-id="DOB-REQUIRED"><span class="clearlabel">Error: </span>Date of birth is required.</div>
//            <div data-rsrc-id="DOB-INVALID"><span class="clearlabel">Error: </span>Date of birth is invalid.</div>
//            <div data-rsrc-id="DOB-FUTURE"><span class="clearlabel">Error: </span>Date of birth must be in the past.</div>
//            <div data-rsrc-id="LEGAL-SEX-REQUIRED"><span class="clearlabel">Error: </span>Legal sex is required.</div>
//            <div data-rsrc-id="RACE"><span class="clearlabel">Error: </span>Race is required.</div>
//            <div data-rsrc-id="ETHNICITY"><span class="clearlabel">Error: </span>Ethnicity is required.</div>
//            <div data-rsrc-id="PREFERRED-LANGUAGE"><span class="clearlabel">Error: </span>Preferred Language is required.</div>
//            <div data-rsrc-id="EMAIL-REQUIRED"><span class="clearlabel">Error: </span>Email address is required.</div>
//            <div data-rsrc-id="EMAIL-INVALID"><span class="clearlabel">Error: </span>Email address is invalid.</div>
//            <div data-rsrc-id="HOME-PHONE-REQUIRED"><span class="clearlabel">Error: </span>Home phone is required.</div>
//            <div data-rsrc-id="PHONE-TYPE-7-INVALID"><span class="clearlabel">Error: </span>Phone number is invalid.</div>
//            <div data-rsrc-id="MOBILE-PHONE-REQUIRED"><span class="clearlabel">Error: </span>Mobile phone is required.</div>
//            <div data-rsrc-id="PHONE-TYPE-1-INVALID"><span class="clearlabel">Error: </span>Phone number is invalid.</div>
//            <div data-rsrc-id="WORK-PHONE-REQUIRED"><span class="clearlabel">Error: </span>Work phone is required.</div>
//            <div data-rsrc-id="PHONE-TYPE-8-INVALID"><span class="clearlabel">Error: </span>Phone number is invalid.</div>
//            <div data-rsrc-id="ADDRESS-REQUIRED"><span class="clearlabel">Error: </span>Address is required.</div>
//            <div data-rsrc-id="CITY-REQUIRED"><span class="clearlabel">Error: </span>City is required.</div>
//            <div data-rsrc-id="COUNTY-REQUIRED"><span class="clearlabel">Error: </span>County is required.</div>
//            <div data-rsrc-id="COUNTY-INVALID"><span class="clearlabel">Error: </span>Please enter a county.</div>
//            <div data-rsrc-id="DISTRICT-REQUIRED"><span class="clearlabel">Error: </span>District is required.</div>
//            <div data-rsrc-id="DISTRICT-INVALID"><span class="clearlabel">Error: </span>Please enter a district.</div>
//            <div data-rsrc-id="HOUSENUMBER-REQUIRED"><span class="clearlabel">Error: </span>House number is required.</div>
//            <div data-rsrc-id="STATE-REQUIRED"><span class="clearlabel">Error: </span>State is required.</div>
//            <div data-rsrc-id="STATE-INVALID"><span class="clearlabel">Error: </span>Please enter a state.</div>
//            <div data-rsrc-id="POSTALCODE-REQUIRED"><span class="clearlabel">Error: </span>ZIP code is required.</div>
//            <div data-rsrc-id="POSTALCODE-INVALID"><span class="clearlabel">Error: </span>Zip code is invalid.</div>
//            <div data-rsrc-id="COUNTRY-REQUIRED"><span class="clearlabel">Error: </span>Country is required.</div>
//            <div data-rsrc-id="COUNTRY-INVALID"><span class="clearlabel">Error: </span>Please enter a country.</div>
//            <div data-rsrc-id="NATIONALID-REQUIRED"><span class="clearlabel">Error: </span>Social Security number is required.</div>
//            <div data-rsrc-id="NATIONALID-INVALID"><span class="clearlabel">Error: </span>Social Security number is invalid. The correct format is ###-##-####.</div>
//            <div data-rsrc-id="NATIONALIDLAST4-REQUIRED"><span class="clearlabel">Error: </span>Social Security number is required.</div>
//            <div data-rsrc-id="PAYOR-REQUIRED"><span class="clearlabel">Error: </span>Insurance is required.</div>
//            <div data-rsrc-id="INSURANCENAME-REQUIRED"><span class="clearlabel">Error: </span>Insurance name is required.</div>
//            <div data-rsrc-id="MEMBERID-REQUIRED"><span class="clearlabel">Error: </span>Member ID is required.</div>
//            <div data-rsrc-id="SUBSCRIBERID-REQURED"><span class="clearlabel">Error: </span>Subscriber ID is required.</div>
//            <div data-rsrc-id="SUBSCRIBERNAME-REQUIRED"><span class="clearlabel">Error: </span>Subscriber name is required.</div>
//            <div data-rsrc-id="SUBSCRIBERDOB-REQUIRED"><span class="clearlabel">Error: </span>Subscriber date of birth is required.</div>
//            <div data-rsrc-id="SUBSCRIBERDOB-INVALID"><span class="clearlabel">Error: </span>Subscriber date of birth is invalid.</div>
//            <div data-rsrc-id="SUBSCRIBERDOB-FUTURE"><span class="clearlabel">Error: </span>Subscriber date of birth must be in the past.</div>
//            <div data-rsrc-id="GROUPID-REQUIRED"><span class="clearlabel">Error: </span>Group number is required.</div>
//            <div data-rsrc-id="LENGTH-EXACTLY-4"><span class="clearlabel">Error: </span>Must be exactly 4 characters.</div>
//            <div data-rsrc-id="MAX-LENGTH-18"><span class="clearlabel">Error: </span>Cannot exceed 18 characters</div>
//            <div data-rsrc-id="MAX-LENGTH-20"><span class="clearlabel">Error: </span>Cannot exceed 20 characters</div>
//            <div data-rsrc-id="MAX-LENGTH-25"><span class="clearlabel">Error: </span>Cannot exceed 25 characters</div>
//            <div data-rsrc-id="MAX-LENGTH-40"><span class="clearlabel">Error: </span>Cannot exceed 40 characters</div>
//            <div data-rsrc-id="MAX-LENGTH-50"><span class="clearlabel">Error: </span>Cannot exceed 50 characters</div>
//            <div data-rsrc-id="OTHER-ERROR"><span class="clearlabel">Error: </span>Something went wrong while processing your request. Please check your information for any obvious errors and try submitting it again. If that doesn't work, contact us for help.</div>
//            <div data-rsrc-id="LOGIN-NOT-AVAILABLE"><span class="clearlabel">Error: </span>That username is not available</div>
//            <div data-rsrc-id="defaultInsuranceImg">/MyChart/Content/images/sampleins.png</div>
//            <div data-rsrc-id="RECAPTCHA-NOT-REACHABLE"><span class="clearlabel">Error: </span>ReCAPTCHA was not reachable. Please try again later.</div>
//            <div data-rsrc-id="CAPTCHA-BLANK"><span class="clearlabel">Error: </span>You must answer the CAPTCHA.</div>
//            <div data-rsrc-id="CAPTCHA-INVALID"><span class="clearlabel">Error: </span>The CAPTCHA entered was invalid. Please try again.</div>
//            <div data-rsrc-id="PASSWORD-MISMATCH"><span class="clearlabel">Error: </span>The retyped password doesn't match the original.</div>
//
//            <div data-rsrc-id="LOGIN-NOT-AVAILABLE-idminmax"><span class="clearlabel">Error: </span>Your username must be between @MYCHART@MINLEN@ and @MYCHART@MAXLEN@ characters.</div>
//            <div data-rsrc-id="LOGIN-NOT-AVAILABLE-idlength"><span class="clearlabel">Error: </span>Your username must have at least 3 characters.</div>
//            <div data-rsrc-id="LOGIN-NOT-AVAILABLE-idformat"><span class="clearlabel">Error: </span>Your username cannot contain any spaces or symbols other than a period (.), hyphen (-), underscore (_), or the at symbol (@).</div>
//            <div data-rsrc-id="LOGIN-NOT-AVAILABLE-idused"><span class="clearlabel">Error: </span>That username is in use already.</div>
//            <div data-rsrc-id="PASSWORD-NOT-VALID-passalphanumeric"><span class="clearlabel">Error: </span>Your password must contain at least one letter and one number.</div>
//            <div data-rsrc-id="PASSWORD-NOT-VALID-password"><span class="clearlabel">Error: </span>Invalid password. Please enter a different password.</div>
//            <div data-rsrc-id="PASSWORD-NOT-VALID-passlength"><span class="clearlabel">Error: </span>Your password must have at least 2 characters.</div>
//            <div data-rsrc-id="PASSWORD-NOT-VALID-passminmax"><span class="clearlabel">Error: </span>Your password must be between @MYCHART@MINLEN@ and @MYCHART@MAXLEN@ characters.</div>
//            <div data-rsrc-id="PASSWORD-NOT-VALID-passid"><span class="clearlabel">Error: </span>Your password must be different than your username.</div>
//
//            </div>
//            <div id="D72B7F4E-B2DD-4A94-8A76-DC628995805C_signup_authentication" class="hidden">
//
//            </div>
//            <div id="484C8283-2719-4E8C-BE5C-666C65903FAD_loginSignup_confirm">
//            <form action="/MyChart/OpenScheduling/SignupAndSchedule/ScheduleAppointment" method="post">                <input type="hidden" class="hidden" name="isconfirmation" value="true" />
//            </form>        </div>
//
//
//
//            <a href="#" class="lb_close cancelworkflow"><span class="clearlabel">Close popup</span></a>
//            </div>
//
//
//
//
//
//
//
//
//            <div id="484C8283-2719-4E8C-BE5C-666C65903FAD_loginSignup_coreScripts" class="hidden">
//
//
//            </div>
//            <div id="484C8283-2719-4E8C-BE5C-666C65903FAD_loginSignup_scripts" class="hidden">
//
//
//
//
//
//            </div>
//            <div id="484C8283-2719-4E8C-BE5C-666C65903FAD_loginSignup_templates" class="hidden">
//
//            </div>
//            <div id="484C8283-2719-4E8C-BE5C-666C65903FAD_loginSignup_resources" class="hidden">
//
//            </div>
//            <div id="484C8283-2719-4E8C-BE5C-666C65903FAD_loginSignup_authentication" class="hidden">
//
//            </div>
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_confirmContainer" class="stepContainer offscreen scrollable">
//            </div>
//            </div>
//            </div>
//
//            <div id="embeddedScheduleNoCookies">
//            <div id="noCookies" class="noCookies jqHidden">
//            <div class="verticalCenter">
//            <div class="icon"></div>
//            <div>
//                <p>
//                    <a href="#" onclick="openWindow(window.location.href, '_blank', 'height=540,width=720'); return false;" id="noCookiesButton" class="button">View available times</a>
//                </p>
//            </div>
//            </div>
//            </div>
//            <div id="noCookiesError" class="noCookies jqHidden">
//
//            <div class="verticalCenter">
//            <div class="icon"></div>
//            <div>
//                <span>
//                    <span class="clearlabel">Error: </span>Please <a href="/MyChart/Help/Cookies" target="_blank">enable cookies</a> to view available times.
//                </span>
//            </div>
//            </div>
//            </div>
//            </div>
//
//
//            <div id="urls" class="hidden">
//            <span id="login-url" data-url="/MyChart/OpenScheduling/Authentication/Login"></span>
//            <span id="signup-url" data-url="/MyChart/OpenScheduling/SignupAndSchedule/LoginSignup"></span>
//            <span id="authcheck-url" data-url="/MyChart/OpenScheduling/Authentication/AuthCheck"></span>
//            <span id="openingsUrl" data-url="/MyChart/OpenScheduling/OpenScheduling/GetOpeningsForProvider"></span>
//            <span id="scheduleUrl" data-url="/MyChart/OpenScheduling/SignupAndSchedule/ScheduleAppointment"></span>
//
//            </div>
//
//
//
//
//
//
//            </div>
//            </div>
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_coreScripts">
//
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_scripts">
//
//
//            <script src="/MyChart/en-us/scripts/wp.captchahelpers.min.js?updateDt=1613203651" type="text/javascript"></script>
//            <script type="text/javascript" src="https://www.google.com/recaptcha/api.js?onload=$$WP$CaptchaHelpers$OnCaptchaLoaded&render=explicit&hl=en" async defer></script>
//            <script src="/MyChart/scripts/utilities/authenticatedcallmanager.min.js?updateDt=1533203510" type="text/javascript"></script>
//
//
//
//
//            <script src="/MyChart/areas/openscheduling/scripts/controllers/embeddedschedulecontroller.min.js?updateDt=1612888670" type="text/javascript"></script>
//            <script src="/MyChart/scripts/ui_framework/support/cards.min.js?updateDt=1533203510" type="text/javascript"></script>
//            <script src="/MyChart/areas/visits/scripts/patientinstructioncontroller.min.js?updateDt=1585604366" type="text/javascript"></script>
//            <script src="/MyChart/areas/visits/templates/patientinstruction.tmpl.js?updateDt=1585604366" type="text/javascript"></script>
//            <script src="/MyChart/scripts/common/viewbinder.min.js?updateDt=1580247516" type="text/javascript"></script>
//            <script src="/MyChart/areas/chartsync/templates/chartsynclightboxcontent.tmpl.js?updateDt=1548828398" type="text/javascript"></script>
//            <script src="/MyChart/areas/chartsync/scripts/models/synchronization.min.js?updateDt=1535752210" type="text/javascript"></script>
//            <script src="/MyChart/areas/chartsync/scripts/controllers/chartsynccontroller.min.js?updateDt=1575482762" type="text/javascript"></script>
//            <script src="/MyChart/scripts/common/hoverviewbinder.min.js?updateDt=1553906550" type="text/javascript"></script>
//            <script src="/MyChart/scripts/models/ui/infobubble.min.js?updateDt=1563302312" type="text/javascript"></script>
//            <script src="/MyChart/templates/ui/infobubble.tmpl.js?updateDt=1563302312" type="text/javascript"></script>
//
//            <script src="/MyChart/areas/scheduling/scripts/helpers/schedulingutilities.min.js?updateDt=1585604366" type="text/javascript"></script>
//            <script src="/MyChart/templates/ui/captcha.tmpl.js?updateDt=1522373002" type="text/javascript"></script>
//            <div class='hidden' id='__CAPTCHAkey' data-captcha-key='6Lfc95cUAAAAADbwIiyIOHG43DxYG2nbPNflbQyT'></div>
//            <script src="/MyChart/scripts/models/captcha/googlerecaptchav2.min.js?updateDt=1612888690" type="text/javascript"></script>
//            <script type="text/javascript" src="https://www.google.com/recaptcha/api.js?onload=$$WP$Captcha$RenderAllCaptcha&render=explicit&hl=en" async defer></script>
//
//
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_templates" class="hidden">
//
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_resources" class="hidden">
//
//            <div data-rsrc-id="providerId" data-rsrc-val="51585"></div>
//            <div data-rsrc-id="visitTypeId" data-rsrc-val="1788"></div>
//            <div data-rsrc-id="departmentId" data-rsrc-val="10554002"></div>
//            <div data-rsrc-id="openingsUrl">/MyChart/OpenScheduling/OpenScheduling/GetOpeningsForProvider</div>
//            <div data-rsrc-id="scheduleUrl">/MyChart/OpenScheduling/SignupAndSchedule/ScheduleAppointment</div>
//
//
//
//
//
//
//
//
//
//
//
//
//
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_authentication" class="hidden">
//
//            </div>
//            <div id="0946B3AC-7639-4F83-94A9-25C30DD9C902_EmbeddedSchedule_styles" class="hidden">
//
//            <link type="text/css" rel="stylesheet" media="All" href="/MyChart/en-us/styles/cards.css?updateDt=1614591991" />
//            <link type="text/css" rel="stylesheet" media="All" href="/MyChart/en-us/styles/component.css?updateDt=1614591991" />
//            <link type="text/css" rel="stylesheet" media="All" href="/MyChart/en-us/styles/calendars.css?updateDt=1614591991" />
//
//
//            <link href="/MyChart/Content/EmbeddedOpenScheduling.css" rel="stylesheet" type="text/css" />
//
//            </div>
//            <div id="logActionUrl" class="hidden">/MyChart/OpenScheduling/Authentication/LogAction</div>
//            </body>
//            </html>
//
//
//            """,
//                                    baseURL: nil)
        // essentially supposed to be a private browser.
        webView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        // Hide Loading spinner heart so we can click on the appointment faster
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.webView.evaluateJavaScript("document.querySelectorAll('[role=\"alert\"]:last-of-type')[0].classList.add(\"hidden\")") { (result, error) in
                if error == nil {
                    
                }
            }
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.canGoBack, webViewStateModel.goBack {
            uiView.goBack()
            webViewStateModel.goBack = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(action: action, webViewStateModel: webViewStateModel)
    }
    
    final class Coordinator: NSObject {
        @ObservedObject var webViewStateModel: WebViewStateModel
        let action: ((_ navigationAction: WebView.NavigationAction) -> Void)?
        
        init(action: ((_ navigationAction: WebView.NavigationAction) -> Void)?,
             webViewStateModel: WebViewStateModel) {
            self.action = action
            self.webViewStateModel = webViewStateModel
        }
        
    }
}

extension WebViewWrapper.Coordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if action == nil {
            decisionHandler(.allow)
        } else {
            action?(.decidePolicy(navigationAction, decisionHandler))
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewStateModel.loading = true
        action?(.didStartProvisionalNavigation(navigation))
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        action?(.didReceiveServerRedirectForProvisionalNavigation(navigation))
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webViewStateModel.loading = false
        webViewStateModel.canGoBack = webView.canGoBack
        action?(.didFailProvisionalNavigation(navigation, error))
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        action?(.didCommit(navigation))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewStateModel.loading = false
        webViewStateModel.canGoBack = webView.canGoBack
        if let title = webView.title {
            webViewStateModel.pageTitle = title
        }
        action?(.didFinish(navigation))
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webViewStateModel.loading = false
        webViewStateModel.canGoBack = webView.canGoBack
        action?(.didFail(navigation, error))
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if action == nil  {
            completionHandler(.performDefaultHandling, nil)
        } else {
            action?(.didRecieveAuthChallange(challenge, completionHandler))
        }
        
    }
}
