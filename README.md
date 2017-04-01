# Ten Photos


Take 10 screenshots of the user's face and store them in a secure way, so that they cannot be read/overwritten by attackers.

- single button when you press it, it will open the front camera of the iOS device
- take 10 pictures of whatever is there
- with an interval of 0.5s between pictures for a total of 5 sec
- save the 10 pictures in a secure persistent storage on the iOS device, using Apple's APIs. 



# Further Considerations

- display the saved photos in the keychain
- allow user to preview images
- allow user to delete images

## Issues

- Keychain API still a pain


## References 

- https://github.com/oettam/camera-controls-demo
- [Keychain code](http://stackoverflow.com/a/42360846/406
- [Apple Sample Code AVCaom-iOS](https://developer.apple.com/library/content/samplecode/AVCam/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010112)