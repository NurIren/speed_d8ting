# speed_d8ting

## Inspiration

As technology advances, the average person relies heavily on phones to do the work for us- we seek convenience, speed and a more hands free experience in regards to technology.
Thus, our lives become more fast-paced to catch up. People tend to take photos of things they wish to remember such as events, assignments and projects. The drawback is that we collect a collage of photos, inevitably forget about them, and thus do not take the time to hand-type it into our calendar.

## What it does

Speed D8t allows a user to snap a photo of a flyer, email, assignment, or whiteboard  which contains event related information and this information is automatically added to your calendar. From the flyer image, speed d8t extracts and processed text using vision and NLP to figure out important information required for your upcoming event. This includes: location, times, dates, websites, and descriptions.

## How I built it

For the convenience of the user, we made an iOS app using Swift. To recognize text and extract, we used the tesseract OCR engine. Extracted text was sent through the Apple Natural Language Processing framework to identify individual words and determine the relevant information. Using the EKEvent Kit built by Apple, we add a new event to the users personal calendar. 

## Challenges I ran into

The biggest challenge we faced was setting up OCR in our app. We implemented Google's Firebase Computer Vision library and tried both on device and on cloud recognition, but were not able to get satisfiable results due to limited built in intelligence and capabilities. For the Google Cloud Vision API, there isn't any documentation for Swift, so figuring out how to make requests became a different type of challenge. While searching, we discovered tesseract's on device OCR built in objective C, and that solved our problem.

## Accomplishments that I'm proud of

Figuring out how to run OCR on iOS and integrating different elements of the project using Swift.


## What I learned

We learned more about the tesseract OCR engine, Swift iOS development, and testing for edge cases, and that we have the resolve to complete a project when it seems that everything has failed.


## What's next for speed_d8ting

More features to add are better OCR recognition (including whiteboard) and being able to import images from your camera roll, and being able to send events directly to your friends. 

## Built by:
 - [@ces131](https://github.com/ces131)
 - [@Ottania](https://github.com/ottania)
 - [@ChloeCiora](https://github.com/ChloeCiora)
 - [@tam128](https://github.com/tam128)
 - [@elneaman](https://github.com/elneaman)
 - [@NurIren](https://github.com/NurIren)
