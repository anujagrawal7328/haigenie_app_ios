import 'package:flutter/material.dart';

import '../services/authRepository.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  late TextEditingController _reasonController;
  bool _consentChecked = false;
  final AuthRepository authRepository = AuthRepository();
  bool isDeleting=false;
  late ScaffoldMessengerState _scaffoldMessenger;
  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> submitAccountDeletionRequest(BuildContext context,ScaffoldMessengerState scaffoldMessenger) async {
    setState(() {
      isDeleting=true;
    });
    final result = await authRepository.accountDeletion();
    if (result == true) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'confirmation link sent on email ',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),);
      }else{
      setState(() {
        isDeleting=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Deletion Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /*    const Text(
              'Please provide a reason for your account deletion request:',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _reasonController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your reason here',
                border: OutlineInputBorder(),
              ),
            ),*/
            const SizedBox(height: 16.0),
            Row(
              children: [
                Checkbox(
                  value: _consentChecked,
                  onChanged: (value) {
                    setState(() {
                      _consentChecked = value!;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                      'I understand that my account and associated data will be permanently deleted.'),
                )
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed:_consentChecked==true?() =>submitAccountDeletionRequest(context,_scaffoldMessenger):null,
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey; // Disabled button color
                    }
                    return Colors.blue; // Enabled button color
                  },
                ),
              ),
              child:isDeleting?const CircularProgressIndicator(color: Colors.white,): const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
