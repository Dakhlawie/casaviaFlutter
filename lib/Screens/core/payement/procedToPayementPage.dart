import 'package:casavia/Screens/core/payement/SecondPagePayement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ProceedToPayementPage extends StatefulWidget {
  const ProceedToPayementPage({Key? key}) : super(key: key);

  @override
  State<ProceedToPayementPage> createState() => _ProceedToPayementPageState();
}

class _ProceedToPayementPageState extends State<ProceedToPayementPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Image.asset(
              "assets/carte.png",
              width: 400,
              height: 400,
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => SecondPagePayement()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Proceed To Payement",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
