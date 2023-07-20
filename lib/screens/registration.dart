import 'package:flutter/material.dart';
import 'package:haigenie/l10n/l10n.dart';

import '../model/user.dart';
import '../services/authRepository.dart';
import 'widgets/customTextField.dart';
enum RoleType { doctor, nurse, pharmacist , admin, others }
List<TextEditingController> createControllers(int count) {
  return List<TextEditingController>.generate(count, (_) => TextEditingController());
}
class RegistrationPopup extends StatefulWidget {
  const RegistrationPopup({super.key});

  @override
  State<StatefulWidget> createState() => _RegistrationPopupState();
}

class _RegistrationPopupState extends State<RegistrationPopup> {
  RoleType _roleType= RoleType.admin;
  late List<TextEditingController> controllers;
  final AuthRepository authRepository = AuthRepository();
  bool registrationFormIsValid = false;
  @override
  void initState() {
    super.initState();
    controllers = createControllers(8);

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
      registrationFormIsValid = controllers[0].text.isNotEmpty && controllers[1].text.isNotEmpty
          && controllers[2].text.isNotEmpty
          && controllers[3].text.isNotEmpty
          && controllers[4].text.isNotEmpty
          && controllers[5].text.isNotEmpty && controllers[7].text.isNotEmpty;
    });
  }

  Future<void> register(ScaffoldMessengerState scaffoldMessenger) async {
    String name = controllers[0].text;
    String organisation = controllers[1].text;
    String email = controllers[2].text;
    String role = _roleType.name;
    String dept = controllers[3].text;
    String district = controllers[4].text;
    String state = controllers[5].text;
    String whatsApp = controllers[7].text;
   if(name.isNotEmpty && organisation.isNotEmpty && email.isNotEmpty && dept.isNotEmpty
       && district.isNotEmpty
       && state.isNotEmpty
       && whatsApp.isNotEmpty){
     final user=User(name: name,organisation: organisation,email: email,whatsappNo: whatsApp,department: dept,district: district,state: state,userType: 'practice');
    final registered = await authRepository.register(user);
    if (registered) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'A verification mail sent on your email',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
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
    }
   }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    controllers[6].text=l10n.india;
    return GestureDetector(
        onTap: (){
          Navigator.of(context).pop();
        },
        child:SingleChildScrollView(child:
        AlertDialog(
      title:Text(l10n.register, style: const TextStyle(color: Colors.black),),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            CustomTextField(
              controller: controllers[0],
              validation: validateRegistrationForm,
              label: '${l10n.fullName}*',
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 10.0),
            CustomTextField(
              controller: controllers[1],
              validation: validateRegistrationForm,
              label: '${l10n.organisation}*',
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 10.0),
            CustomTextField(
              controller: controllers[2],
              validation: validateRegistrationForm,
              label: '${l10n.email}*',
              textInputType: TextInputType.emailAddress,

            ),
          const SizedBox(height: 10.0),
          CustomTextField(
            controller: controllers[7],
            validation: validateRegistrationForm,
            label: '${l10n.mobileNumber}*',
            textInputType: TextInputType.number,
          ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<RoleType>(
              value: _roleType,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: '${l10n.role}*',
                border: const OutlineInputBorder(),
                filled: true, // Set the field to be filled
                fillColor: Colors.white,
              ),
              items: RoleType.values.map((RoleType roleType) {
                return DropdownMenuItem<RoleType>(
                  value: roleType,
                  child: Text(l10n.roleType(roleType
                      .toString()
                      .split('.')
                      .last), style: const TextStyle(color: Colors.grey),),
                );
              }).toList(),
              onChanged: (RoleType? value) {
                setState(() {
                  _roleType = value!;
                });
              },
            ),
            const SizedBox(height: 10.0),
            CustomTextField(
              controller: controllers[3],
              validation: validateRegistrationForm,
              label: '${l10n.dept}*',
              textInputType: TextInputType.name,
            ), const SizedBox(height: 10.0),
            CustomTextField(
              controller: controllers[4],
              validation: validateRegistrationForm,
              label: '${l10n.district}*',
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 10.0),
            CustomTextField(
              controller: controllers[5],
              validation: validateRegistrationForm,
              label: '${l10n.state}*',
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 10.0),
            CustomTextField(
              controller: controllers[6],
              validation: validateRegistrationForm,
              label: l10n.country,
              readOnly: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              key: const Key('registerButton'),
              onPressed: registrationFormIsValid
                  ? () {
                register(ScaffoldMessenger.of(context));
                Navigator.of(context).pop();
              } : (){},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (!states.contains(MaterialState.disabled) &&
                          registrationFormIsValid) {
                        return Colors.blue; // Enabled button color
                      }
                      return Colors.grey;
                    }),
              ),
              child: Container(
                width: double.infinity,
                height: 50.0,
                alignment: Alignment.center,
                child: Text(
                  l10n.register,
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
    )));

  }


}