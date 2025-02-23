# Testing the transport API as a swift widget

### Javascript implementation: https://github.com/flokleiser/TransportAPITest 
### Transport API: https://transport.opendata.ch/

___

Current links: 
- https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension
- https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications#Add-WidgetKit-complications-to-your-existing-watchOS-app

To-Do:

- Currently both WatchOS and IOS widgets only function in one direction -> change it so they accept the UserDefautls from the apps
- Also currently, WatchOS has its own implementation of TransportService -> adapt it from TransportData.swift like the ios app

- [ ] Rewrite phone widget completely
- [ ] Rewrite WatchOS app to use TransportData.swift


- [ ] Widget properly updating 
- [ ] Better interface to choose other stations
- [x] WatchOS Complication properly updating
- [x] Add apple watch complication so i can put it on a watch face
- [x] Make widget display 3 departure times

Done:
- [x] Apple watch app
- [x] IOS app
- [x] Functioning widget

___

![](TramDisplay/Preview%20Content/Preview%20Assets.xcassets/preview.png)