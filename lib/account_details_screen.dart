import 'package:flutter/material.dart';
import 'package:myapp/homepage.dart'; // Assuming Loan model is in homepage.dart
// Simple data model for a transaction
class Transaction {
  final String date;
  final String description;
  final String amount;
  final bool isCredit;

  Transaction({
    required this.date,
    required this.description,
    required this.amount,
    this.isCredit = false,
  });
}

class AccountDetailsScreen extends StatelessWidget {
  final Loan loan;

  const AccountDetailsScreen({Key? key, required this.loan}) : super(key: key);
  static const List<Widget> TransactionHistory = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(loan.title),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          // Loan Details Section
          _buildSection(
            title: 'Loan Information',
            action: IconButton(
              icon: const Icon(Icons.more_vert),//more icon to the extreme of text, I changed from Icon to const Icon to stop possible issues as you say in the requirements
              onPressed: () {
                // TODO: Implement action menu for more details
                print('view more options');
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Account No:'+loan.accountId), _buildDetailRow('Loan Amount:', loan.amount), //Added null check to prevent app crash.
                   Text('Principal Outstanding:', textAlign: TextAlign.center), //Implement
                   Text('Balance Tenure:', textAlign: TextAlign.center),//Implement
                   Text('Rate of Interest:', textAlign: TextAlign.center), //Implement
                ]  ,),),
            ),     //Downloads Section
              _buildSection(
            title: 'Download',
            action: IconButton(
              icon: const Icon(Icons.download_outlined),//more icon to the extreme of text, I changed from Icon to const Icon to stop possible issues as you say in the requirements
              onPressed: () { //function to do the work for downloads
                // TODO: Implement download logic, for now just display SnackBar

                      ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Downloading information')),
                           );
              },
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('These action is used for downloading. You can add to this now!'),
              ],
            ),
          ),   //Transaction Code section
          _buildSection(
            title: 'Transaction History',
            action: IconButton(
              icon: const Icon(Icons.more_vert),//more icon to the extreme of the application status title
              onPressed: () { //implement action download icon pressed
                // TODO: Implement action menu for download or what not
                 ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('History page, the list will show here')),
                           );
                print('downloading things');
              },
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Here are supposed to be some transactions or downloads'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSection({required Widget child, required String title, Widget? action, }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
       child: Column(children: [  Row(        crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [  Text(title,style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),), action ?? const SizedBox.shrink()   ]),          child,    ]
        ),
    );
  }


  // Helper widget for detail rows
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper widget for download list tiles
  Widget _buildDownloadTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      trailing: const Icon(Icons.download_outlined, color: Colors.grey),
      onTap: () {
        // TODO: Implement download logic
        print('Downloading $title');
      },
    );
  }
}
