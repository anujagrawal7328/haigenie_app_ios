import 'package:flutter/material.dart';
import 'package:haigenie/l10n/l10n.dart';

import '../services/authRepository.dart';
import 'widgets/customTextField.dart';

List<TextEditingController> createControllers(int count) {
  return List<TextEditingController>.generate(count, (_) => TextEditingController());
}
class ForgotPasswordPopup extends StatefulWidget {
  const ForgotPasswordPopup({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordPopupState();
}

class _ForgotPasswordPopupState extends State<ForgotPasswordPopup> {

  late List<TextEditingController> controllers;
  final AuthRepository authRepository = AuthRepository();
  bool formIsValid = false;
  @override
  void initState() {
    super.initState();
    controllers = createControllers(1);
  }

  @override
  void dispose(){
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void validateRegistrationForm() {
    setState(() {
      formIsValid = controllers[0].text.isNotEmpty;
    });
  }

  Future<void> reset(ScaffoldMessengerState scaffoldMessenger) async {
    String email = controllers[0].text;

    if(email.isNotEmpty){
     /* final registered = await authRepository.register(email);
      if (registered) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'A verification mail sent on your email',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Registration Failure',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }*/
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return    GestureDetector(
        onTap: (){
          Navigator.of(context).pop();
        },
        child:
        AlertDialog(
          title: Text(l10n.passwordReset, style: TextStyle(color: Colors.black),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              CustomTextField(
                controller: controllers[0],
                validation: validateRegistrationForm,
                label: '${l10n.email}*',

              ),

              const SizedBox(height: 20.0),
              ElevatedButton(
                key: const Key('resetButton'),
                onPressed: formIsValid
                    ? () {
                  reset(ScaffoldMessenger.of(context));
                  Navigator.of(context).pop();
                } : (){},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (!states.contains(MaterialState.disabled) &&
                            formIsValid) {
                          return Colors.blue; // Enabled button color
                        }
                        return Colors.grey;
                      }),
                ),
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  alignment: Alignment.center,
                  child:Text(
                    l10n.reset,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));

  }
}