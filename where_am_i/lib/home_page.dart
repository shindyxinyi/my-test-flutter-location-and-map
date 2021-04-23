import 'package:flutter/material.dart';
import 'package:where_am_i/map_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Where Am I?'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: NetworkImage(
                  'https://scx2.b-cdn.net/gfx/news/hires/2018/location.jpg'),
              height: 150.0,
            ),
            SizedBox(height: 35.0),
            Text(
              'Where Am I?',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50.0),
            RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              },
              child: Text(
                'Let\'s Go!',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              color: Colors.redAccent,
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}
