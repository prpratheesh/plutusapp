import 'package:flutter/material.dart';

// This widget will handle the response from the payment gateway
class ResponsePage extends StatelessWidget {
  // You can add query parameters or other data handling as needed
  final Map<String, String>? queryParams;

  const ResponsePage({Key? key, this.queryParams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Response')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Response',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (queryParams != null && queryParams!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: queryParams!.length,
                  itemBuilder: (context, index) {
                    final key = queryParams!.keys.elementAt(index);
                    final value = queryParams![key];
                    return ListTile(
                      title: Text('$key: $value'),
                    );
                  },
                ),
              )
            else
              Center(child: Text('No response data available.')),
          ],
        ),
      ),
    );
  }
}
