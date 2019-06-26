# CBLLogViewer
## Overview 
This mac application will display all the information from the couchbase xcode log text file. Choose to filter the logs with the domain or level. 

## How to run the project
1. `git clone https://github.com/jayahariv/CBLLogViewer.git`
2. `cd CBLLogViewer/CBLLogViewer`
3. `open CBLLogViewer.xcodeproj`
4. Choose a signing team, for provisioning.
5. Run the application

## How to download direct application
1. download the latest [release](https://github.com/jayahariv/CBLLogViewer/releases)
2. open it. 
3. system preference -> security and privacy -> open anyway. to allow the application to run. 
4. open the application again. 


## How to check the logs
### How to load 
#### File log(from 2.5.x onwards)
1. Choose the _verbose log_ through the `browse` button.

#### Console log 
1. Copy the console log to a _text file_. 
2. Choose the _txt file_ through the `browse` button. 

### Features
- For Filtering logs, check/uncheck the the web-socket, BLIP, Sync, Query, DB checkboxes. 
- For Search, enter any keyword and click search. Once done, click clear button.  
- For details, choose the line and you can copy contents; or if you choose multiple lines, you can click copy to copy all those message to clipboard.
- For Console logging, BLIP & Webscoket logs are combined in console logs. And this can be filtered through BLIP. 


## Screenshots
!<img width="400" alt="Screen Shot 2019-04-06 at 2 19 22 PM copy" src="https://user-images.githubusercontent.com/10448770/55675431-38466200-5877-11e9-8e3e-e8ea14f33d60.png">
!<img width="400" alt="Screen Shot 2019-04-06 at 2 19 49 PM" src="https://user-images.githubusercontent.com/10448770/55675435-53b16d00-5877-11e9-99c0-6dfc976cb11f.png">
