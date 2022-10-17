import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:tailorware/screens/home_screen.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isCheckedRememberMe = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final ipAddressController = TextEditingController();
  bool isLoading = false;
  String error = '';

  void authenticateUser(username, password, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    var server = prefs.getString('server');
    if (server == null || server.isEmpty) {
      setState(() {
        error = 'No Server Found to connect';
      });
      return;
    }

    String baseUrl = 'http://$server/api/v1';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/users/authenticate?username=$username&password=$password'),
      );

      if (response.statusCode == 200) {
        final Map user = json.decode(response.body);

        setState(() {
          error = "";
        });

        // save username in the global prefrences
        await prefs.setString('username', user['user']['username']);
        // save name in the global prefrences
        await prefs.setString('name', user['user']['name']);
        // save userId in the global prefrences
        await prefs.setString('userId', user['user']['_id']);

        if (isCheckedRememberMe) {
          await prefs.setBool('remember', true);
        }

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          // the new route
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen(),
          ),
          (Route route) => false,
        );
      } else {
        setState(() {
          error = "Invalid Username Or Password";
        });
      }
    } catch (e) {
      setState(() {
        error = '$e';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void getServer() async {
    final prefs = await SharedPreferences.getInstance();
    var server = prefs.getString('server');
    setState(() {
      ipAddressController.text = server!;
    });
  }

  @override
  void initState() {
    super.initState;
    getServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                right: 20,
                top: 20,
                child: IconButton(
                  onPressed: () {
                    showPlatformDialog(
                      context: context,
                      builder: (context) => BasicDialogAlert(
                        title: const Center(child: Text("Tailorware Server")),
                        content: SizedBox(
                          height: 80,
                          child: Column(
                            children: [
                              // username TextField
                              TextField(
                                controller: ipAddressController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Server", //babel text
                                  prefixIcon: Icon(
                                    Icons.computer,
                                    color: Colors.grey,
                                  ), //prefix iocn
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ), //hint text style
                                ),
                              ),
                              // password TextFeild
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            child: const Text("Save"),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              // save server in the global prefrences
                              await prefs.setString(
                                'server',
                                ipAddressController.text,
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
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

                    error != ''
                        ? Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.left,
                            ),
                          )
                        : const SizedBox(
                            height: 20,
                          ),

                    // Login Button
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              var username = usernameController.text;
                              var password = passwordController.text;
                              authenticateUser(
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
                      child: isLoading
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
            ],
          ),
        ),
      ),
    );
  }
}
