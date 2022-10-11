import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authenticateUserfn,
    required this.isLoading,
    required this.error,
  });
  final dynamic authenticateUserfn;
  final bool isLoading;
  final String error;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isCheckedRememberMe = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
            child: Column(
              children: [
                // Login Title
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Welcome Text
                const Text(
                  "Welcome to\n Tailorware by casriware",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 50,
                ),
                // username TextField
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username", //babel text
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.grey,
                    ), //prefix iocn
                    labelStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ), //hint text style
                  ),
                ),
                // password TextFeild
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password", //babel text
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ), //prefix iocn
                    labelStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ), //hint text style
                  ),
                ),
                // sizedBox
                const SizedBox(
                  height: 20,
                ),
                // remember Me
                Row(
                  children: [
                    Checkbox(
                      value: isCheckedRememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          isCheckedRememberMe = value!;
                        });
                      },
                    ),
                    const Text(
                      "Remember Me",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                // sizedBox

                widget.error != ''
                    ? Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          widget.error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : const SizedBox(
                        height: 20,
                      ),

                // Login Button
                ElevatedButton(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          var username = usernameController.text;
                          var password = passwordController.text;
                          widget.authenticateUserfn(
                            username,
                            password,
                            context,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(300, 10),
                    disabledForegroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(10),
                    textStyle: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: widget.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Login"),
                ),

                // sizedBox
                const SizedBox(
                  height: 30,
                ),
                // Contact Us
                const Text(
                  "For Support Contact Us",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Numbers
                const Text(
                  "0615753832 / 0616549198",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Gmail
                const Text(
                  "casriware@gmail.com",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                // website
                const Text(
                  "www.casriware.co",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Copyright © 2022 Tailorware \n All rights reserved",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
