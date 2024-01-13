import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: Container(child: Row(children: [
        const Expanded(
          child: LeftMainContainer(),
        ),
        Expanded(child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleGroupedChips<int>(

                            controller: pageFiltercontroller,
                            onItemSelected: (selected){
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
                              checkedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              selectedIcon: null,
                              selectedColorItem: Color(0xffe0b0ff),
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
                            padding: const EdgeInsets.symmetric(vertical:8.0),
                            child: selectedAuthType == 0 ? LoginForm() : SignupForm(),
                          ),
                          SizedBox(height: 30,),
                          selectedAuthType == 0 ?  LoginSignupButton(buttonText: "Login") : LoginSignupButton(buttonText:"Signup")
            ],
          ),
                   
        ))
      ],)),
    );
  }
}

class LoginSignupButton extends StatelessWidget {
  String buttonText = "";
    LoginSignupButton({
    super.key,
    required this.buttonText
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        maximumSize: MaterialStateProperty.all(Size(400,50))
      ),
      onPressed: (){}, child: Container(
     
      child: Center(child: Text(buttonText, style: GoogleFonts.lato(textStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 16)),)),));
  }
}

class SignupForm extends StatelessWidget {
   SignupForm({
    super.key,
  });
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
     return Form(
        
        key: formKey,child: Column(children: [
        Text("Create an Account",style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),),
        const SizedBox(height: 40,),
       
          TextFormField(
            
            controller: emailController,
            validator: (value) {
              bool isURLValid =  value!.length > 3;
              if(!isURLValid){
                 return "Invalid Email";
              }
              return null;
            },
  decoration: const InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    constraints: BoxConstraints(
      maxWidth: 400,
    ),
    labelText: 'Enter your email'
  )
          )
     , SizedBox(height: 10)
      , TextFormField(
            
            controller: emailController,
            validator: (value) {
              bool isURLValid =  value!.length > 3;
              if(!isURLValid){
                 return "Invalid password";
              }
              return null;
            },
            
  decoration:  InputDecoration(
    suffixIcon: Icon(Icons.lock),
    suffixIconColor: Color(0xffe0b0ff),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    constraints: BoxConstraints(
      maxWidth: 400,
    ),
    labelText: 'Enter your password'
  )
          )
       
        ]
        )
    );
  
  }
}

class LoginForm extends StatelessWidget {
   LoginForm({
    super.key
  });
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        
        key: formKey,child: Column(children: [
        Text("Login",style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),),
        const SizedBox(height: 40,),
       
          TextFormField(
            
            controller: emailController,
            validator: (value) {
              bool isURLValid =  value!.length > 3;
              if(!isURLValid){
                 return "Invalid Email";
              }
              return null;
            },
  decoration: const InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    constraints: BoxConstraints(
      maxWidth: 400,
    ),
    labelText: 'Enter your email'
  )
          )
     , SizedBox(height: 10)
      , TextFormField(
            
            controller: emailController,
            validator: (value) {
              bool isURLValid =  value!.length > 3;
              if(!isURLValid){
                 return "Invalid password";
              }
              return null;
            },
            
  decoration:  InputDecoration(
    suffixIcon: Icon(Icons.lock),
    suffixIconColor: Color(0xffe0b0ff),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10))
    ),
    constraints: BoxConstraints(
      maxWidth: 400,
    ),
    labelText: 'Enter your password'
  )
          )
       
        ]
        )
    );
  
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
                    
                    text:  TextSpan(
                      children:   [
                  TextSpan(text: 'folio', style: GoogleFonts.lato(textStyle:TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 54,fontWeight: FontWeight.w900))
                      )
                ],
                      text: 'Binge', style:GoogleFonts.lato(textStyle:const TextStyle(color: Colors.black, fontSize: 54,fontWeight: FontWeight.w900))
                      )),
          Text("Portfolios from across the world!", style: GoogleFonts.lato(textStyle:TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 32,fontWeight: FontWeight.w300)))
        ],
      ),
    );
  }
}