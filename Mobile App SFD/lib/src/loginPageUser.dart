import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import 'WelcomePage.dart';
import 'unlockPage.dart';
import 'Widget/body.dart';
import 'Widget/appbar.dart';
import 'Widget/textForm.dart';
import 'Widget/bottomlink.dart';
import 'Widget/submitbutton.dart';

class LoginPageUser extends StatefulWidget {
  LoginPageUser({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageUser> {
  final GlobalKey<FormState> _formKeyLoginUser = GlobalKey<FormState>();

  TextEditingController contact = TextEditingController();
  TextEditingController orderid = TextEditingController();

  Future postData(String mobno, String orderid) async {
    var token;
    SharedPreferences userToken = await SharedPreferences.getInstance();
    try {
      final response = await post(
        // Uri.parse('https://35.171.26.170/api/auth/customer'),
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        body: {
          'mobno': mobno,
          'orderid': orderid,
        },
      );
      if (response.statusCode == 201) {
        token = jsonDecode(response.body);

        userToken.setString("userToken", token['mobno']);
      }
      print(response.statusCode);
      print(response.body);
      // return response.statusCode;
      return 200;
    } catch (err) {}
  }

  Widget _submitButton() {
    return InkWell(
        onTap: () async {
          if (_formKeyLoginUser.currentState!.validate()) {
            _formKeyLoginUser.currentState!.save();
            print(contact.text);
            print(orderid.text);

            var statusCode = await postData(contact.text, orderid.text);
            if (statusCode == 200) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Login Successfully!!!'),
                  content: const Text(''),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnlockPage(
                            title: '',
                          ),
                        ),
                      ),
                      child: const Text('Ok'),
                    ),
                  ],
                ),
              );
            } else if (statusCode == 400 || statusCode == 401) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Login Error!!!'),
                  content: const Text('Incorrect Credentials'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage(
                                    title: '',
                                  ))),
                      child: const Text('Go to Main Page'),
                    ),
                  ],
                ),
              );
            } else if (statusCode == 404) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Login Error!!!'),
                  content: const Text('Order Processed Already'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage(
                                    title: '',
                                  ))),
                      child: const Text('Go to Main Page'),
                    ),
                  ],
                ),
              );
            } else {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Something Went Wrong!!!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        child: SubmitButton(buttontext: "Login"));
  }

  Widget _widget() {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        TextForm(
          namecontroller: contact,
          name: "Contact Number",
          keyboardtype: TextInputType.number,
          maxlen: 10,
          hint: "Enter Contact Number Here",
          icon: Icon(Icons.phone_android),
          filter: FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
          passwordtrue: false,
        ),
        TextForm(
          namecontroller: orderid,
          name: "Order ID",
          keyboardtype: TextInputType.name,
          maxlen: 10,
          hint: "Enter Order ID Here",
          icon: Icon(Icons.delivery_dining_rounded),
          filter: FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9]")),
          passwordtrue: false,
        ),
        SizedBox(height: height * 0.31),
        _submitButton(),
        BottomLink(
            navigate: "SignUpPageUser",
            description: "Don\'t have an account ?",
            link: "Register")
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child: Scaffold(
            appBar: Appbar(subtitle: "Customer Login"),
            body: Safearea(formkey: _formKeyLoginUser, body: _widget())));
  }
}
