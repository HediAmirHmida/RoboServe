import 'package:flutter/material.dart';
import 'commande.dart';

class CommandeDetailsPage extends StatelessWidget {
  final Commande commande;

  const CommandeDetailsPage({Key? key, required this.commande}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Commande Details',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue[900],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Food:', '${commande.text}'),
                _buildDetailItem('Table Number:', '${commande.tableNumber}'),
                _buildDetailItem('Notes:', '${commande.note}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue[900],
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
