TUMitfahrer
===========

<!--[![Build Status](https://travis-ci.org/pkwiecien/tumitfahrer.png?branch=master)](https://travis-ci.org/pkwiecien/tumitfahrer)-->

New backend for TUMitfahrer App build with Ruby on Rails.
Any endpoint such as Android, iOS, Pebble apps can communicate with the backend via JSON format.


Architecture of TUMitfahrer
---------------------------

![Alt text](https://raw.githubusercontent.com/pkwiecien/tumitfahrer/master/public/architecture.png
"Domain model of TUMitfahrer showing all classes and relationships between them")


Domain Model
------------

Domain model is shown on the class diagram below (click to zoom):
![Alt text](https://github.com/pkwiecien/tumitfahrer/raw/master/public/ClassDiagram.png
"High level architecture diagram of TUMitfahrer")


API Reference
-------------

#### Sessions

Type | URI | Explanation
--- | --- | ---
*POST* | `/sessions` | create a new session for the user. Required paramters: `email, hashed_password`

#### Users

http://www.tumitfahrer.de/api/v1/users

Type | URI | Explanation
--- | --- | ---
*GET* | `/users` | get all users
*GET* | `/users/1` | get user no. 1
*POST* | `/users` | create a new user
*PUT* | `/users/1` | update user no. 1.   Optional parameters `phone_number (string), rank (integer), exp (float), car (string), unbound_contributions (integer), department (integer), hashed_password (string), hashed_password_confirmation (string), gamification (boolean)`


#### Rides

http://www.tumitfahrer.de/api/v1/rides

Type | URI | Explanation
--- | --- | ---
*GET* | `/rides` | get all rides
*GET* | `/rides/1` | get ride no. 1
*GET* | `/users/1/rides` | get all rides of user no. 1. Optional parameter `is_paid=true (boolean)` returns rides that are paid for by the user
*POST* | `/users/1/rides` | create a new ride for user no. 1. This user is a driver
*PUT* | `/users/1/rides/2` |
*DELETE* | `/users/1/rides/2` | delete a ride no. 2 for user no. 1  

#### Devices

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/1/devices` | get all devices of the user no. 1
*POST* | `/users/1/devices` | create a new device for the user no. 1. Parameters `token (string), enabled (boolean), platform (string)`. Platform is one of: `android, ios, windows`

#### Friend Requests

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/1/friend_requests` | get all friend request of the user no. 1
*POST* | `/users/1/friend_requests` | create new friend request of the user no. 1. Parameters: `to_user_id (integer)`
*PUT* | `/users/1/friend_requests/2` | handle a friend request between user no. 1 and user no 2. Parameter: `accept (boolean)`. Both users become friends if :accept is true and at the end friend request is destroyed.

#### Friends

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/1/friends` | get all friends of user no. 1

#### Messages

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/1/messages` | get all messages of user no. 1. Parameters: `receiver_id (integer)`
*GET* | `/users/1/messages/2` | get a specific message for user no 1 from user no 2.
*POST* | `/users/1/messages/` | create a new message for user no. 1. Parameter: `receiver_id (integer), content (string)`
*PUT* | `/messages/1` | update message no. 1 and mark it as seen. Paramter: `is_seen (boolean)`

#### Passengers

Type | URI | Explanation
--- | --- | ---
*GET* | `/rides/1/passengers` | get all passenger of the ride no. 1
*PUT* | `/rides/1/passengers/2` | update a ride for a passenger no 2. Parameters: `contribution_mode, realtime_km`

#### Payments

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/1/payments` | get all payments of the user no. 1. Optional parameter: `pending=true (boolean)`
*POST* | `/users/1/payments` | create a new payment from user no. 1. Required parameters: `ride_id (integer), amount (float), from_user_id (integer)`


#### Projects

Type | URI | Explanation
--- | --- | ---
*GET* | `/projects` | get all projects. Optional parameters: `offered=true (boolean)`
*GET* | `/projects/1` | get project no. 1
*POST* | `/users/1/projects/` | create a new project with user no. 1 as owner. Parameters: `fundings_target (float), description (string), title (string), fundings_target (float)`
*PUT* | `/projects/1` | update project no. 1. Parameters: `phase, title, description`


#### Ratings

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/1/ratings` | get all ratings (both given and received) of user no 1. Optional parameters: `pending=true (boolean).
*POST* | `/users/1/ratings` | create new rating for user no. 1. Parameters: `to_user_id, ride_id, rating_type`

#### Ride Requests

Type | URI | Explanation
--- | --- | ---
*POST* | `/rides/1/requests` | create a new ride request for a ride no. 1. Parameters: `user_id (integer), requested_from (string), requested_to (string)`
*PUT* | `/rides/1/requests` | handle ride request for a ride no. 1. Parameters: `passenger_id (integer), departure_place (string), destination (string), confirmed (boolean)`

#### Contributions

Type | URI | Explanation
--- | --- | ---
*GET* | `/users/1/contributions` | get all contributions of the user no. 1
*POST* | `/users/1/contributions` | create a new contribution from user no 1. Parameters `amount (float), project_id (integer)`
*POST* | `/users/1/rides/2/contributions` | create a new contribution from user no. 1 for ride no. 2
*DELETE* | `/users/1/contributions/2` | delete a contribution from user  no. 1 for project no. 2

#### Search

Type | URI | Explanation
--- | --- | ---
*POST* | `/search` | search for a ride. Parameters `start_carpool (string), end_carpool (string), ride_date (datetime)`


Contributions
-------------

In the architecture diagram I used following icon licensed under Creative Commons Attribution that should be attributed:
* Smart Phone by Emily Haasch from The Noun Project
* Code by buzzyrobot from The Noun Project
* Database by Stefan Parnarov from The Noun Project
* Application by Brian Gonzalez from The Noun Project
* User by Rémy Médard from The Noun Project

