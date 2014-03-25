iOS Rift Experiment
===================
This is a starter project for creating iOS apps that support the Oculus Rift. It's basically the project you get when you create a new OpenGL project in Xcode plus some support code to render stereo graphics on the Rift display.

Supporting the Rift
-------------------
Here is the summary of the enhancements to the basic OpenGL project:

1. Detect the attachment of the Rift as an external display. You need a [Lightning-to-HDMI cable](http://www.amazon.com/gp/product/B009WHV3BM/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B009WHV3BM&linkCode=as2&tag=lanephillips) to connect the Rift to your iOS device.
2. Split the screen into viewports for the left and right eyes. Render the scene into each viewport. This is called "passive stereo" when both views are sent to the same frame buffer. It's called "bi-ocular" viewing when both eyes see identical views.
3. Set up the projection matrices for the left and right eyes. I used the parameters given in the Rift development kit documentation. You are now viewing the scene in true binocular stereo.
4. **Not Implemented:** Correct the radial distortion caused by the Rift optics. This requires a shader to distort the scene in the opposite way.
5. **Not Implemented:** Somehow get data from the orientation sensors into the app. Possibly you could connect the Rift's USB cable to a Raspberry Pi that has a server program to provide the data over WiFi or Bluetooth LE. Or an MFI-approved company could make some sort of dongle that passed the data through the Lightning connector.

Notes
-----
The Lightning-to-HDMI cable has an HDMI output and another Lightning port. You might think that you can debug through this port, but unfortunately it's for charging only. You will have to load the app through a USB cable, then disconnect it and connect the Rift. Due to this inconvenience I added logging output to the iOS device's screen.

The Rift will not display anything on the screen unless its USB cable for the orientation sensors is plugged in. 

The Rift SDK actually includes Objective-C code for a Mac OS demo. It might have been a better idea to just port it to iOS.

To-Do List
----------
These are things I need to do yet, but considering I haven't touched this project in almost a year, you are welcome to implement these and submit a pull request:

1. Implement the distortion correction as mentioned above.
2. Get the sensor data as mentioned above.
3. Experiment with using the multitouch panel as a way of navigating a scene.
4. For even more fun, it wouldn't be too hard to render a touch interface to a texture and show it in the scene.

