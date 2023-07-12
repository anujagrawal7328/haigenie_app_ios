import 'package:flutter/material.dart';
import 'package:haigenie/screens/widgets/customTextField.dart';

import '../services/authRepository.dart';
List<TextEditingController> createControllers(int count) {
  return List<TextEditingController>.generate(count, (_) => TextEditingController());
}
class UpdatePassword extends StatefulWidget {
  final String? email;
  final String? token;
  const UpdatePassword({super.key,required this.email,required this.token});
  @override
  State<StatefulWidget> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  late List<TextEditingController> controllers;

  final AuthRepository authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _formIsValid = false;
  late ScaffoldMessengerState _scaffoldMessenger;
  @override
  void initState() {
    controllers = createControllers(3);
    controllers[2].text=widget.email!;
    super.initState();
  }
  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  _validateForm() {
    setState(() {
      _formIsValid =( controllers[0].text ==
          controllers[1].text);
    });
  }

  Future<void> update(ScaffoldMessengerState scaffoldMessenger) async {
    String password = controllers[0].text;
    String email = controllers[2].text;
    String token = widget.token!;
    final isUpdated = await authRepository.updateNewUser(email,password,token);
    if (isUpdated) {
      Navigator.pushReplacementNamed(context, '/auth');
      scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Success',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),);
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid username or password',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
     }
  }

  @override
  Widget build(BuildContext context) {

    _scaffoldMessenger = ScaffoldMessenger.of(context); // Initialize _scaffoldMessenger
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 120.0, 20.0, 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.0,
                height: 120.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/Images/logo.png'), // Replace with your image path
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              CustomTextField(
                controller: controllers[2],
                validation: _validateForm,
                label: 'Email*',
                textInputType: TextInputType.emailAddress,
                readOnly: true,
                icon: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(height: 10.0),
              CustomTextField(
                controller: controllers[0],
                validation:  _validateForm,
                label: 'Password*',
                icon: const Icon(Icons.lock, color: Colors.grey),
                obscurePassword: _obscurePassword,
                iconButton: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 10.0),
              CustomTextField(
                controller: controllers[1],
                validation:  _validateForm,
                label: 'Confirm Password*',
                icon: const Icon(Icons.lock, color: Colors.grey),
                obscurePassword: _obscurePassword,
                iconButton: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed:
                _formIsValid ? () => update(_scaffoldMessenger) : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey; // Disabled button color
                      }
                      return Colors.blue; // Enabled button color
                    },
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  alignment: Alignment.center,
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}