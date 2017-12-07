# OpenStack Destroyer

University Name: [San Jose State University](http://www.sjsu.edu/)

Course: [Virtualization Technologies](http://info.sjsu.edu/web-dbgen/catalog/courses/CMPE281.html)

Professor [Thomas Hildebrand](https://www.linkedin.com/in/thhildebrand/)

Team: Group #6



## Introduction:
OpenStack Destroyer is a cross-platform game that interacts with OpenStack via API and CLI. You pilot a spaceship that can destroy, pause, unpause, create instances. You can also open a CLI interface to send commands directly to OpenStack.



## Screenshots:
![alt text](https://dl.dropboxusercontent.com/s/dpd4uzgostyczf0/openstackdestroyer-screens.png "App screenshots")



## Pre-requisites:

Frontend (mobile app): [Corona SDK](https://www.coronalabs.com)

Backend: Java with OpenStack4j and OpenStack (Labs version running on top of Virtual Box)



## How to setup:
1. Install the required softwares (Corona SDK, Java, OpenStack4j and OpenStack Labs version)
2. Download / clone this repo;
3. Replace the PROJ_ID variable (at OpenstackController.java) with one of your own project id (you can get it from OpenStack Horizon dashboard)
4. Start the Java backend (Go to "backend/openstack/os-service/target" and execute "nohup java -cp os-service-1.0.jar service.RestService &"")
5. Open the app project using Corona SDK


