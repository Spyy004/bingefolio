import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';
import 'package:surffolio/main.dart';




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GroupController pageFiltercontroller = GroupController(initSelectedItem: [0]);
  int selectedAuthType = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // body: AuthLaptop(),
    body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return authLaptop();
          } else {
            return authMobile();
          }
        },
      ),
   
    );
  }

  Container authLaptop() {
    return Container(
        child: Row(
      children: [
        const Expanded(
          child: LeftMainContainer(),
        ),
        Expanded(
            child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleGroupedChips<int>(
                controller: pageFiltercontroller,
                onItemSelected: (selected) {
                  setState(() {
                    selectedAuthType = selected;
                  });

                  // setState(() {
                  //   orderBy = tempA;
                  //   isDescending = tempB;
                  // });
                },
                values: const [0, 1],
                chipGroupStyle: ChipGroupStyle.minimize(
                  checkedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  selectedIcon: null,
                  selectedColorItem: const Color(0xffe0b0ff),
                  disabledColor: Colors.green,
                  backgroundColorItem: Colors.white,
                  itemTitleStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                itemsTitle: const [
                  "Login",
                  "Create an Account",
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: selectedAuthType == 0 ? LoginForm() : SignupForm(),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ))
      ],
    ));
  }

  Container authMobile() {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: LeftMainContainer(),
        ),
        SimpleGroupedChips<int>(
          controller: pageFiltercontroller,
          onItemSelected: (selected) {
            setState(() {
              selectedAuthType = selected;
            });

            // setState(() {
            //   orderBy = tempA;
            //   isDescending = tempB;
            // });
          },
          values: const [0, 1],
          chipGroupStyle: ChipGroupStyle.minimize(
            checkedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            selectedIcon: null,
            selectedColorItem: const Color(0xffe0b0ff),
            disabledColor: Colors.green,
            backgroundColorItem: Colors.white,
            itemTitleStyle: const TextStyle(
              fontSize: 16,
            ),
          ),
          itemsTitle: const [
            "Login",
            "Create an Account",
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: selectedAuthType == 0 ? LoginForm() : SignupForm(),
        ),
        const SizedBox(
          height: 30,
        )
      ],
    ));
  }

}

class SignupForm extends StatefulWidget {
  SignupForm({
    super.key,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  bool isObscure = true;

  final formKey = GlobalKey<FormState>();

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  void showGenericToast(message) {
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.CENTER,
        msg: message,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        webBgColor: '#E0B0FF',
        webPosition: "center");
  }

  void createUserinDB() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      showGenericToast("Account created succesfully");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const MyHomePage(
                    title: 'Bingefolio',
                  )),
          (Route<dynamic> route) => false);
//  Navigator.pushAndRemoveUntil(context,
//  MaterialPageRoute(builder: (context)
//  {
//             return MyHomePage(title: 'Bingefolio',);
//           },),
//          predicate: false );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showGenericToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showGenericToast('The account already exists for that email.');
      } else {
        showGenericToast(e.code);
      }
    } catch (e) {
      showGenericToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(children: [
          Text(
            "Create an Account",
            style: GoogleFonts.lato(
                textStyle:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(
            height: 40,
          ),
          TextFormField(
              controller: emailController,
              validator: (value) {
                final bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(emailController.text);
                if (!emailValid) {
                  return "Invalid Email";
                }
                return null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  constraints: BoxConstraints(
                    maxWidth: 400,
                  ),
                  labelText: 'Enter your email')),
          const SizedBox(height: 10),
          TextFormField(
              controller: passwordController,
              validator: (value) {
                bool isURLValid = validateStructure(passwordController.text);
                if (!isURLValid) {
                  return "Invalid password";
                }
                return null;
              },
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: isObscure
                        ? const Icon(Icons.lock)
                        : const Icon(Icons.lock_open),
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                  ),
                  suffixIconColor: const Color(0xffe0b0ff),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  labelText: 'Enter your password')),
          const SizedBox(
            height: 30,
          ),
          OutlinedButton(
              style: ButtonStyle(
                  maximumSize: MaterialStateProperty.all(const Size(400, 50))),
              onPressed: () {
                if (formKey!.currentState!.validate()) {
                  createUserinDB();
                }
              },
              child: Container(
                child: Center(
                    child: Text(
                  "Signup",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16)),
                )),
              ))
        ]));
  }
}

class LoginForm extends StatefulWidget {
  LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  bool isObscure = true;

  final formKey = GlobalKey<FormState>();

  void showGenericToast(message) {
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.CENTER,
        msg: message,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        webBgColor: '#E0B0FF',
        webPosition: "center");
  }

  bool showLoader = false;

  void loginUser() async {
    try {
      setState(() {
        showLoader = true;
      });
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
        currentUser = credential.user;
      showGenericToast("Welcome back!");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const MyHomePage(
          title: 'Bingefolio',
        );
      }));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showGenericToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showGenericToast('Wrong password provided for that user.');
      } else {
        showGenericToast(e.code);
      }
    } catch (e) {
      showGenericToast(e.toString());
    } finally {
      setState(() {
        showLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(children: [
          Text(
            "Login",
            style: GoogleFonts.lato(
                textStyle:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(
            height: 40,
          ),
          TextFormField(
              controller: emailController,
              validator: (value) {
                final bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(emailController.text);
                if (!emailValid) {
                  return "Invalid Email";
                }
                return null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  constraints: BoxConstraints(
                    maxWidth: 400,
                  ),
                  labelText: 'Enter your email')),
          const SizedBox(height: 10),
          TextFormField(
              obscureText: isObscure,
              controller: passwordController,
              validator: (value) {
                bool isURLValid = validateStructure(passwordController.text);
                if (!isURLValid) {
                  return "Invalid password";
                }
                return null;
              },
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: isObscure
                        ? const Icon(Icons.lock)
                        : const Icon(Icons.lock_open),
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                  ),
                  suffixIconColor: const Color(0xffe0b0ff),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  labelText: 'Enter your password')),
          const SizedBox(
            height: 30,
          ),
          OutlinedButton(
              style: ButtonStyle(
                  maximumSize: MaterialStateProperty.all(const Size(400, 50))),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  loginUser();
                }
              },
              child: Container(
                child: Center(
                    child: showLoader ? const RiveAnimation.asset("assets/loader.riv"):Text(
                  "Login",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16)),
                ),
                ),
              ))
        ]));
  }
}

class LeftMainContainer extends StatelessWidget {
  const LeftMainContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(
                  children: [
                TextSpan(
                    text: 'folio',
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 54,
                            fontWeight: FontWeight.w900)))
              ],
                  text: 'Binge',
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 54,
                          fontWeight: FontWeight.w900)))),
          Text("Portfolios from across the world!",
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w300)))
        ],
      ),
    );
  }
}

bool validateStructure(String value) {
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}
