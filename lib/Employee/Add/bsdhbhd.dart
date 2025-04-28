import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IFSCCheckerScreen extends StatefulWidget {
  const IFSCCheckerScreen({super.key,required BuildContext menuScreenContext});

  @override
  _IFSCCheckerScreenState createState() => _IFSCCheckerScreenState();
}

class _IFSCCheckerScreenState extends State<IFSCCheckerScreen> {
  final TextEditingController _ifscController = TextEditingController();
  String? branch, city, state, bank;
  Timer? _debounce;

  // Fetch bank details from API
  Future<void> getDetails(String ifscCode) async {
    final url = Uri.parse('https://ifsc.razorpay.com/$ifscCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        branch = data['BRANCH'];
        city = data['CITY'];
        state = data['STATE'];
        bank = data['BANK'];
      });
    } else {
      setState(() {
        branch = city = state = bank = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid IFSC Code")),
      );
    }
  }

  // Debounce textfield changes
  void _onIFSCChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 600), () {
      if (value.length == 11) {
        getDetails(value);
      } else {
        setState(() {
          branch = city = state = bank = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _ifscController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("IFSC Code Checker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ifscController,
              maxLength: 11,
              decoration: InputDecoration(
                labelText: 'Enter IFSC Code',
                border: OutlineInputBorder(),
              ),
              onChanged: _onIFSCChanged,
            ),
            SizedBox(height: 20),
            if (branch != null) ...[
              Text("Bank: $bank", style: TextStyle(fontSize: 18)),
              Text("Branch: $branch"),
              Text("City: $city"),
              Text("State: $state"),
            ],
          ],
        ),
      ),
    );
  }
}
