import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key});

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  List<int> ratings = List.filled(5, 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeaderImage(),
            SizedBox(height: 20),
            buildRatingQuestions(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.sentiment_satisfied,
                              color: Colors.blue[900], size: 20),
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 8), // Add a SizedBox for space
                        ),
                        TextSpan(
                          text: 'What did you like? ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.sentiment_dissatisfied,
                              color: Colors.blue[900], size: 20),
                        ),
                        WidgetSpan(
                          child: SizedBox(width: 8),
                        ),
                        TextSpan(
                          text: 'What didn\'t you like? ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'FINISH',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeaderImage() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Image.asset(
          'assets/hotel_room_4.jpg',
          width: MediaQuery.of(context).size.width,
          height: 250,
          fit: BoxFit.cover,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grand Hayat Guest House', // Hotel name
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '11 Nov - 12 Nov',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRatingQuestions() {
    return Column(
      children: [
        buildRatingQuestion("How were the staff?", 0),
        buildRatingQuestion("How were the facilities?", 1),
        buildRatingQuestion("Was it clean?", 2),
        buildRatingQuestion("Was it comfortable?", 3),
        buildRatingQuestion("How was the location?", 4),
      ],
    );
  }

  Widget buildRatingQuestion(String question, int questionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(question,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 0,
          runSpacing: 0,
          children: List.generate(10, (index) {
            return IconButton(
              icon: Icon(
                size: 25,
                ratings[questionIndex] > index ? Icons.star : Icons.star_border,
                color: ratings[questionIndex] > index
                    ? Colors.blue[900]
                    : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  ratings[questionIndex] = index + 1;
                });
              },
            );
          }),
        ),
      ],
    );
  }
}
