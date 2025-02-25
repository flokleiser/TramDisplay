# Testing the transport API as a swift widget/Apple Watch complication 

**JavaScript implementation**: https://github.com/flokleiser/TransportAPITest 
**Transport API**: https://transport.opendata.ch/

___

Current links: 

- Sanity check: https://www.zvv.ch/de/fahrplan-und-informationen/fahrplan.html?tab=connections&fromid=A%3D1%40O%3DZ%C3%BCrich%2C%20Toni-Areal%40X%3D8510699%40Y%3D47390187%40U%3D89%40L%3D8591398%40B%3D1%40p%3D1739255639%40&fromlat=47.390187&fromlon=8.510699&fromname=Z%C3%BCrich%2C%20Toni-Areal&toid=A%3D1%40O%3DZ%C3%BCrich%2C%20Rathaus%40X%3D8542881%40Y%3D47371741%40U%3D89%40L%3D8591309%40B%3D1%40p%3D1739255639%40&tolat=47.371741&tolon=8.542881&toname=Z%C3%BCrich%2C%20Rathaus

- https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension
- https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications#Add-WidgetKit-complications-to-your-existing-watchOS-app

To-Do:

Currently the two available tram stations are hard coded, tbd -> enable user input and then choose from list

- [ ] Add more complication support
- [ ] Better interface to choose other stations
- [x] Add refresh button for apple watch app
- [x] Widget properly updating 
- [x] Rewrite WatchOS app to use TransportData.swift
- [x] WatchOS Complication properly updating
- [x] Add apple watch complication so i can put it on a watch face
- [x] Make widget display 3 departure times
- [x] Apple watch app
- [x] IOS app
- [x] Functioning widget

___

![](TramDisplay/Preview%20Content/Preview%20Assets.xcassets/preview.png)