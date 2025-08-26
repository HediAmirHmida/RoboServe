import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'commande.dart';
import 'CommandeDetailsPage.dart';
import 'LoginPage.dart';
import 'bluetooth.dart'; // Import bluetooth.dart file

void main() => runApp(MaterialApp(
  home: LoginPage(),
  debugShowCheckedModeBanner: false,// Change this to LoginPage() which will be the entry point
));

class TestRoboServe extends StatefulWidget {
  const TestRoboServe({Key? key}) : super(key: key);

  @override
  State<TestRoboServe> createState() => _TestRoboServeState();
}

class _TestRoboServeState extends State<TestRoboServe> {
  List<Commande> commandes = [];
  late Timer _timer;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    fetchCommandes(); // Initial fetch when the widget initializes
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchCommandes(); // Polling every 5 seconds
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> fetchCommandes() async {
    try {
      final response =
      await http.get(Uri.parse('http://192.168.1.66:3000/get-commandes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          commandes = data
              .map((item) => Commande(
            num: item['num'],
            text: item['text'],
            note: item['note'],
            tableNumber: item['tableNumber'],
            currentState: item['currentState'],
          ))
              .toList();
        });
      } else {
        throw Exception('Failed to fetch commandes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching commandes: $e');
    }
  }

  Future<void> deleteCommande(int id) async {
    try {
      final response = await http.delete(
          Uri.parse('http://192.168.1.66:3000/delete-commande/$id'));
      if (response.statusCode == 200) {
        setState(() {
          commandes.removeWhere((commande) => commande.num == id);
        });
      } else {
        throw Exception('Failed to delete commande: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting commande: $e');
    }
  }

  Future<void> updateCommandeState(int id, String newState) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.66:3000/update-commande/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'currentState': newState}),
      );
      if (response.statusCode == 200) {
        fetchCommandes(); // Refresh the commandes list after update
        if (newState == 'Ready to deliver') {
          final commande =
          commandes.firstWhere((element) => element.num == id);
          //sendSignalToSTM32(commande.tableNumber, _scaffoldMessengerKey);
          //await sendBluetoothData('BF600', 'hello', _scaffoldMessengerKey);
          await Future.delayed(Duration(seconds: 2));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green, // Customize background color
              content: Text(
                'Order was sent to the robot successfully',
                style: TextStyle(color: Colors.white), // Customize text color
              ),
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating, // Set behavior to floating for a better look
            ),
          );
        }
      } else {
        throw Exception(
            'Failed to update commande state: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating commande state: $e');
    }
  }

  Widget commandeTemplate(Commande commande) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            "${commande.num}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          "Commande #${commande.num}",
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Food: ${commande.text}",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Table Number: ${commande.tableNumber}",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                _showStateOptionsDialog(commande);
              },
              child: Text(commande.currentState),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            deleteCommande(commande.num);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CommandeDetailsPage(commande: commande),
            ),
          );
        },
      ),
    );
  }

  void _showStateOptionsDialog(Commande commande) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change State"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  updateCommandeState(commande.num, "In preparation");
                  Navigator.pop(context);
                },
                child: const Text("In preparation"),
              ),
              ElevatedButton(
                onPressed: () {
                  updateCommandeState(commande.num, "Ready to deliver");
                  Navigator.pop(context);
                },
                child: const Text("Ready to deliver"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: Text(
          "order queues",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[100], // Dark blue-grey background color
        elevation: 0, // Remove app bar shadow
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Implement logout functionality here
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: commandes.length,
        itemBuilder: (context, index) {
          return commandeTemplate(commandes[index]);
        },
      ),
    );
  }
}
