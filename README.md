# Paper2Video
2018 Maker's Week Project

On [NYT Video](www.nytimes.com/video), videos are paired with links to related web articles and vice-versa, however, no such connection exists between videos and related print articles. Paper2Video aims to bridge that gap by allowing users to access NYT videos using the camera on their iOS device and a prominent image from the print article.

### Setup
A free developer account needs to be created at [Clarifai](www.clarifai.com) to handle the image recognition. Create a new application with a general workflow. Make note of the API key for the application. Using the [Clarifai API](https://clarifai.com/developer/guide/search#search), you can upload the image you want to map to a video or you can do it via browser using Clarifai Explorer. It is important that the filename matches the ID of the corresponding NYT video. For example, a video with ID **100000006341479** needs to match to a file named **100000006341479.jpg** or **100000006341479.png**. To map multiple images to the same video use an underscore followed by a unique string after the ID in the file name like **100000006341479_01.jpg** and **100000006341479_02.jpg**.

Clone the repo and create a file called `Clarifai.plist` inside of the `Paper2Video\Paper2Video` directory with the Clarifai API key in this format:
![img](https://i.imgur.com/xOhvaxU.png)

### How To Use It
1) Find an image or images that are used in the paper or magazine.
2) Name them after the ID of the video that they correspond to.
3) Upload them to Clarifai.
4) Align the camera of the iOS device so that the entire print image is in the field of view with little to no outside space. (Only potrait and right-handed landscape orientations are supported.)
5) Press the button and watch the video play on the device.

### Development
**Greg Joshua** - Concept and app development

### Special Thanks
- **Adam Schott** - *Technology (iOS)* - Technical advice 
- **Veronique Brossier** - *Technology (iOS)* - Technical advice 
- **Deborah Auer** - *Newsroom (Art)* - Providing physical paper assets to corresponding videos
-  **Francisco Souza** - *Technology (Video)* - Helping with the Video API
- **Mannish Mittal** - *Technology (iOS)* - Support with device testing
