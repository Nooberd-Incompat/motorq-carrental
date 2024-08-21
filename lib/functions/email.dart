import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendEmail(String recipient, String subject, String body) async {
    const String apiKey =
      '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';
  final Uri url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

  final Map<String, dynamic> emailData = {
    'personalizations': [
      {
        'to': [
          {'email': recipient}
        ],
        'subject': subject,
      },
    ],
    'from': {'email': 'kar10andyoyoyojith@gmail.com'},
    'content': [
      {
        'type': 'text/plain',
        'value': body,
      },
    ],
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: json.encode(emailData),
  );

  if (response.statusCode == 202) {
    print('Email sent successfully');
  } else {
    print('Failed to send email: ${response.body}');
  }
}

