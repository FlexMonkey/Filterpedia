# Filterpedia
Core Image Filter explorer

![screenshot](/Filterpedia/assets/screenshot.jpg)

*Filterpedia* is an iPad app for exploring (almost) the entire range of image filters offered by Apple's Core Image framework. It is designed as a companion app to my upcoming book, [_Core Image for Swift_](https://itunes.apple.com/de/book/core-image-for-swift/id1073029980?l=en&mt=11) which is due for publication in February 2016. 

The UI is split into two sections: the table view on the left allows the user to navigate through and select a filter, the panel on the right then displays all the parameters of the selected filter which can be adjusted using horizontal sliders.

*Filterpedia* is also a showcase for custom filters I'm creating that are discussed in the book. These include simple compositions of existing `CIFilter`, `CIKernel` based filters using GLSL and filters that use Metal kernel functions as their filtering engine.
