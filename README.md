TUMitfahrer
===========

[![Build Status](https://travis-ci.org/pkwiecien/tumitfahrer.png?branch=master)](https://travis-ci.org/pkwiecien/tumitfahrer)

TUMitfahrer Web App as well as REST API for mobile clients. Backend is written in Ruby on Rails.

System overview
-------------

![Alt text](https://raw.githubusercontent.com/pkwiecien/tumitfahrer/develop/public/system_diagram.png
"System overview showing interaction of clients with the server")


Development process of TUMitfahrer
---------------------------

![Alt text](https://raw.githubusercontent.com/pkwiecien/tumitfahrer/master/public/development_process_diagram.png
"High level overview of the development process of TUMitfahrer")


Domain Model
------------

Domain model is shown on the class diagram below (click to zoom):
![Alt text](https://github.com/pkwiecien/tumitfahrer/raw/master/public/ClassDiagram.png
"Domain model of TUMitfahrer showing all classes and relationships between them")

Roadmap: 
-------

Elements being implemented:

* backend in Rails and REST API (Pawel)
* iOS app (Pawel)
* web app using Haml/jQuery (Anuradha, Shahid)
* Android app (Abhijith, Amr)
* Pebble app and VisioM intergration(Saqib, Behroz)
* Test framework (Dansen)
* UI and UX (Lukasz)


API Reference
-------------

To use API, use for now http://tumitfahrer-staging.herokuapp.com/.
Each API call starts with `/api/v2` and is followed by a specific verb, e.g. http://tumitfahrer-staging.herokuapp.com/api/v2/rides.

If it's not clear what should be e.g. format of parameters, check out how is the API implemented and try to reverse engineer it. The API functions are [HERE](https://github.com/pkwiecien/tumitfahrer/tree/develop/app/controllers/api/v2). The output of API controllers is defined in serializers [HERE](https://github.com/pkwiecien/tumitfahrer/tree/develop/app/serializers).


Currenlty not all API requests require api_key in request header, however, soon it will be added on backend so it will be required to get a response.

#### Sessions

TUMitfahrer has existing user base of over 1000 users. Their passwords are obviously encrypted and cannot be read. The idea is to create a authentication system that will enable old users as well as new ones to login in. Therefore the authentication mechanism is a bit complex.

To login to TUmitfahrer you need to create a POST request to sessions. In the header `Authorization: Basic`, you should provide encrypted credentials in the form: `base64_encryption(username:sha512_encryption(password+'toj369sbz1f316sx'))`. sha512_encryption is a standard encryption algorithm whose implementation you can find on the Internet, and here it's used to encrypt password with added salt 'toj369sbz1f316sx' (the salt is taken from the old system). `username:sha512_encryption` are again encrypted with base64 encryption.

So to sum up, pass a header in form:
`Authorization: Basic base64_encryption(username:sha512_encryption(password+'toj369sbz1f316sx'))`


Type | URI | Explanation
--- | --- | ---
*POST* | `/sessions` | create a new session for the user. Required header: `email, hashed_password`

#### Users

http://tumitfahrer-staging.herokuapp.com/api/v2/users

To create a new user, create a POST request to `/users`

Type | URI | Explanation
--- | --- | ---
*GET* | `/users` | get all users. Response `{ "users": [ {"id": 1, ...} ] }`. For full response see [HERE](http://tumitfahrer-staging.herokuapp.com/api/v2/users)
*GET* | `/users/:user_id` | get a specific user. Required header: `Authorization: Basic encrypted_email_and_password`. For encrypted password and email, see above. Response: `{"user": {"id": 1, ...} }`
*POST* | `/users` | create a new user, required parameters as json: `{"user" : { "email" : "xyz@tum.de", "first_name": "Name", "last_name": "Name", "department": department_id}}`  where departmentNo is a number of faculty (faculties are taken is alpabethic order from : http://www.tum.de/en/about-tum/faculties/, so e.g. Architecture has departmentNo `0`)
*PUT* | `/users/:user_id` | update a specific user. Required header: `Authorization: Basic encrypted_email_and_password`. For encrypted password and email, see above.  Parameters that can be updated: `phone_number:  string, car : string, department : integer, hashed_password : string, password_confirmation : string, first_name : string, last_name : string`. Password and password_confirmation are required parameters.


#### Rides

http://tumitfahrer-staging.herokuapp.com/api/v2/rides

Type | URI | Explanation
--- | --- | ---
*GET* | `/rides?page=0` | get all rides by page.  Response `{ "rides": [ {"id": 1, ...} ] }`. For full response see [HERE](http://tumitfahrer-staging.herokuapp.com/api/v2/rides)
*GET* | `/rides?from_date` | get all rides that were updated after `from_date : date, ride_type : integer`. Ride type = 0 is campus ride, ride type = 1 is activity ride.
*GET* | `/rides/ids` | get ids of rides that exists in webservice. This method is called on a mobile client to check which rides should be deleted from the local database
*GET* | `/rides/:ride_id` | get a specific ride.  Response `{ "ride": [ {"id": 1, ...} ] }`. 
*GET* | `/users/:user_id/rides` | get all rides of specific user. Optional parameters: `driver=true` returns rides where user is driver. `passenger=true` returns rides where user passenger. `past=true` return all past rides of the user.
*POST* | `/users/:ride_id/rides` | create a new ride for specific user. This user will become ride owner (it can be ride as driver or ride request). Required header: `api_key: string`, which is api key of this user. Ride params: `"ride" : {"departure_place": string, "destination": string, "departure_time": date, "free_seats" : integer, "meeting_point" : string, "ride_type" : intger (0->campus, 1-> activity), "is_driving" : true, "car" : string, "departure_latitude" : double, "departure_longitude" : double, "destination_latitude": double, "destination_longitude":double }` 
*PUT* | `/users/:user_id/rides/:ride_id` | Update a specific ride. Parameters : `"ride" : {"departure_place": string, "destination": string, "departure_time": date, "free_seats" : integer, "meeting_point" : string, "ride_type" : intger (0->campus, 1-> activity)` 
*PUT* | `/users/:user_id/rides/:id?removed_passenger=id` | Update a ride by removing a passenger with a given id.
*DELETE* | `/users/:user_id/rides/:ride_id` | delete a given ride. 

#### Activities

http://tumitfahrer-staging.herokuapp.com/api/v2/activities

Type | URI | Explanation
--- | --- | ---
*GET* | `/activities` | get all activities of what happened in a system. Parameters: `activity_id : integer`, where activity id is id of returned activities object. For a sample response see: [tumitfahrer](http://tumitfahrer-staging.herokuapp.com/api/v2/activities)
*GET* | `/activities/badges` | get a number of new activities that happened after a specific time which is given in parameters. Parameters: `campus_updated_at=date&activity_updated_at=date&timeline_updated_at=date&my_rides_updated_at=date&user_id:id`. Sample response: `{"badge_counter":{"id":0,"created_at":date,"timeline_badge":integer,"timeline_updated_at":date,"campus_badge":45,"campus_updated_at": date,"activity_badge":integer,"activity_updated_at":date,"my_rides_badge":integer,"my_rides_updated_at":date}}`


#### Devices

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/:user_id/devices` | get all devices of a specific user. Sample response: `{"devices":[{"id":4,"user_id":75,"token":"abc","created_at":"2014-05-06T20:14:23.872+02:00","updated_at":"2014-05-06T20:14:23.872+02:00","enabled":true,"platform":"ios","language":null}],"status":"ok"}`
*POST* | `/users/:user_id/devices` | create a new device for specific user. Parameters should be of the form: `{ "device" : { "token" :string, "enabled" : boolean, "platform" :string }}`. Platform is one of: `android, ios, windows`

#### Conversations

Each ride has a list of conversations between a driver and passenger. Each conversation consits of Messages.

Type | URI | Explanation
--- | --- | ---
*GET* | `/rides/:ride_id/conversations` | get all conversations for a specific ride. No parameters. Response has a form: `{"conversations":[{"id":integer,"user_id": integer,"other_user_id": integer,"ride": Ride,  "messages":[{"id":68,"content": string,"is_seen":false,"sender_id": : integer,"receiver_id": integer,"created_at": date,"updated_at": date}]}]}`
*GET* | `/rides/:ride_id/conversations/:id` | get a specific message for conversation for a specific ride. Response is above with `conversation` instead of `conversations`.

#### Messages

Type | URI | Explanation
--- | --- | ---
*GET* | `/rides/:ride_id/conversations/:conversation_id/messages` | Create a message in a given conversation for a specific ride. Parameters: `sender_id : integer, receiver_id : integer, content : string`. Response is a status message: `"message" : string (success or not), status : status_code`.

#### Ratings


Type | URI | Explanation
--- | --- | ---
*GET* | `/users/:user_id/ratings` | get all ratings (both given and received) of a specific user. Parameters: `given: boolean`. Given is true for getting given ratings, given is false for getting received ratings. Example response: `{"ratings":[{"rating_type":1,"from_user_id":95,"to_user_id":75,"ride_id":481,"created_at":"2014-06-19T10:57:59.372+02:00","updated_at":"2014-06-19T10:57:59.372+02:00"}]}`
*POST* | `/users/:user_id/ratings` | create new rating from a specific user. Parameters: `to_user_id : integer, ride_id : intger, rating_type : integer`. Respose is newly created Rating.

#### Ride Requests

Type | URI | Explanation
--- | --- | ---
*GET* | `/rides/:ride_id/requests/` | Get all requests for a ride with given id.  Response `{ "requests": [ {"id": integer, "passenger_id" : integer, "ride" : Ride, created_at : date, updated_at : date} ] }`. 
*GET* | `/users/:ride_id/requests/` | Get all user's requests. Response with Request (see above).
*POST* | `/rides/:ride_id/requests` | create a new ride request for a specific ride. Parameters: `passenger_id : integer`. Response: newly created Request
*PUT* | `/rides/:ride_id/requests/:id` | handle ride request for a specific ride. Parameters: `passenger_id : integer, confirmed : boolean`
*DELETE* | `/rides/:ride_id/requests/:id` | delete a ride requests for a given ride.

#### Search

Type | URI | Explanation
--- | --- | ---
*POST* | `/search` | search for a ride. Parameters `departure_place : string, departure_place_threshold : integer, destination : string, destination_threshold : integer, departure_time : date, ride_type :integer`. Response is an array of Rides.

#### Forget password

Type | URI | Explanation
--- | --- | ---
*POST* | `/forgot` | send a password reminder to a given user specifiec by email provided in parameters. Parameters `email : string`. Response is a status message: `"message" : string (successfully sent to email or not), status : status_code`.

#### Feedback

Type | URI | Explanation
--- | --- | ---
*POST* | `/feedback` | create a feedback for us from user. Parameters `user_id : integer, title : string, content : string`. Response is a status message: `"message" : string (whether successfully sent or not), status : status_code`.



Discarded API calls:
---------------------------

* friend_requests
* friends
* payments
* contributions
* projects
* passnegers

Contributions
-------------

In the architecture diagram I used following icon licensed under Creative Commons Attribution that should be attributed:
* Smart Phone by Emily Haasch from The Noun Project
* Code by buzzyrobot from The Noun Project
* Database by Stefan Parnarov from The Noun Project
* Application by Brian Gonzalez from The Noun Project
* User by Rémy Médard from The Noun Project

