import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:lottie/lottie.dart';

import '../services/auth.dart';



class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF05B397),
        Color(0xFFD61A8B),
          ],
        ),

      ),
      child: OnBoardingSlider(
        finishButtonText: 'Let’s Chat',

        finishButtonStyle: FinishButtonStyle(
          elevation: 5,
          backgroundColor: Color(0xFF075E54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          )


        ),

        onFinish: () async {
          final user = await AuthMethods().getCurrentUser();

          if (user != null) {
            Navigator.pushReplacementNamed(context, '/home');
            print("Logged in as: ${user.displayName}");
            print("Email: ${user.email}");

           // You can also print stored shared preferences if needed:
           //  final username = await SharedPreferenceHelper().getUserUsername();
           //  print("Username: $username");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please sign in first")),
            );
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        skipTextButton:  Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 50,
            width: 80,
            decoration: BoxDecoration(
              color: Color(0xFF075E54),
              borderRadius: BorderRadius.circular(30),

            ),

            child: Center(
              child: Text('skip',

                style: TextStyle(

                  color: Colors.grey[100],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
            ),
          ),
        ),
        trailing: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 50,
            width: 80,
            decoration: BoxDecoration(
              color: Color(0xFF075E54),
              borderRadius: BorderRadius.circular(30),

            ),

            child: Center(
              child: Text('Login',

              style: TextStyle(

                color: Colors.grey[100],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
          ),
        ),
        trailingFunction: () => Navigator.pushNamed(context, '/login',
        ),
        controllerColor: Colors.greenAccent,
        totalPage: 3,
        speed: 2, // ✅ ADD THIS LINE (required)
        headerBackgroundColor: Colors.white,
        pageBackgroundColor: Colors.white,
        background: [
          Center  (child:
            Lottie.asset('assets/welcome.json'
          , height: MediaQuery.of(context).size.height*0.55,
          width: MediaQuery.of(context).size.width*1,
              fit: BoxFit.contain,

          repeat:true,),),
          Lottie.asset('assets/secure.json'
            , height: MediaQuery.of(context).size.height/1.7,
            width: MediaQuery.of(context).size.width/0.96,


            repeat: true,),
          Lottie.asset('assets/connect.json'
            , height: MediaQuery.of(context).size.height/1.8,
            width: MediaQuery.of(context).size.width/0.95,

            repeat: true,),
        ],

        pageBodies: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Welcome to NexChat',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50), // Adjust spacing from dots
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Secure & Fast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Text(
                  'Ready to Chat?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 0),
            ],
          ),
        ],
      ),
    );
  }
}


