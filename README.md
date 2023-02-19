# BiteBuddies

## **What Inspired Us**

Whether you're just moving into college, starting a job in a new town, or undergoing any sort of life-changing event, making friends is both difficult and necessary.

BiteBuddies is the revolutionary social media network that helps you connect with others using the universal necessity - food! As a bonus, it reduces food waste and encourages healthier eating!

With BiteBuddies, you can simply take a picture of your grocery receipt and add its items to your virtual "pantry." When you're ready, you'll be recommended various recipes people have proposed that match the ingredients in your virtual pantry. With your BiteBuddies partner, you can combine "pantries" to cook a sustainable, healthy, and delicious meal together.

Not only does BiteBuddies remove a barrier to entry of meal prep by recommending recipes that work with what you already have, but it also helps reduce food waste by encouraging users to utilize the ingredients they already have rather than buying more. 

But BiteBuddies isn't just about reducing food waste; it's also about providing a common goal that users can work towards. With this task, the awkwardness of the first meeting with a stranger is minimized by the familiar rhythm of cooking. We hope that users will be encouraged to connect with their BiteBuddies partners again and again!

Entering a new stage in your life doesn't have to be lonely. Download BiteBuddies today and start saving money, reducing waste, and connecting with others who share your love for healthy eating!

## **What We Learned**
We learned that trying to learn a programming language in just a few hours isn't practical, but it's possible to grasp the basics. We now know how to implement an API and call it using a GET API call. We also learned the benefits of creating a microservice application instead of a monolithic one. In terms of mobile app development, we learned that it differs from web development, and it's essential to consider the unique challenges that come with it. Lastly, we now understand the importance of sleep and its impact on overall productivity and health.

## **How We Built Our Project**
For our project, we first went through an ideation phase to identify the verticals we wanted to target and the everyday problems we wanted to solve. We narrowed down our focus to food and sustainability, specifically targeting the problem of new college students leaving their parents’ home cooked meals behind at home, and the inherent loneliness that comes with leaving your family. We decided to build a mobile app, primarily focusing on iOS using Swift, as a platform to solve this problem. To support our app, we built a Flask API with RESTful endpoints that performs CRUD operations on users and interfaces with the Spoonacular API for food classification and recipe recommendations based on user ingredient input. Additionally, we used the Vision.framework to implement OCR and transcribe text from images of receipts. The Flask API and Swift application are two standalone microservices that interact with each other through API calls, forming the backbone of our solution.

## **Challenges We Faced**
Our team faced various challenges while learning and implementing Swift programming language for our project. The first challenge was to adapt to Swift's unique approach to problem-solving, which was different from how we traditionally approached computer science problems. We struggled with decomposing our code and integrating microservices that worked separately but had incompatible inputs and outputs. We also faced issues with function calls and dependencies. Another challenge was the shortage of MacBooks, as we only had two for a team of four, which made collaboration difficult. Additionally, we underestimated the amount of work required for Swift and overestimated the work needed for Flask. Lastly, we encountered Info.plist issues, which prevented us from using Apple user info. Overall, our team had to overcome numerous obstacles while learning and implementing Swift, which required a great deal of effort and persistence.
