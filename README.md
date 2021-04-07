# UniversityAppointments

University Checker is an iOS app that checks the University Health Systems (San Antonio) website for any available COVID-19 vaccines. 

![IMG_5745](https://user-images.githubusercontent.com/2459642/113802410-4f4b1380-9720-11eb-91d4-45b0924b908b.PNG)

If the app is running in the foreground, you can start checking for appointments periodically with a configurable delay. 

The app automatically opens the custom in-app browser when appointments are detected.

## Autofill
When appointments become available, it's often difficult to quickly type in all the required fields such as first name, last name, date of birth, address, etc. If you're not quick enough, you could lose the appointment slot to someone who is faster than you are. By using the autofill feature, you can schedule appointments for people very quickly by filling out demographic information before appointments are available. When appointments become available, you can quickly autofill people's information to minimize the chances of the appointment being captured by someone else before you.

![IMG_5747](https://user-images.githubusercontent.com/2459642/113802552-85889300-9720-11eb-8c71-add56634f3c6.PNG)


## Push Notifications
University Checker uses Firebase Cloud Messaging to send push notifications to the app when appointments are available. 

There is currently a python script running on a Heroku server that checks for appointments periodically. When it detects appointments, it makes a service call to Firebase, which sends a push notification to any apps subscribed to a specific *Appointments* topic.
