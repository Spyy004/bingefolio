import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:rive/rive.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';


void main()async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
 await Hive.openBox("bingefolio");
  runApp(const MyApp());
}
final db = FirebaseFirestore.instance;
class MyApp extends StatelessWidget {
 
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bingefolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BingeFolio'),
    );
  }
}




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
 
  GroupController developerFiltercontroller = GroupController();
  GroupController portfolioTypeFiltercontroller = GroupController();
  GroupController sortFiltercontroller = GroupController();
  TextEditingController urlController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  var box = Hive.box('bingefolio');
  String selectedDevType = "";
  String selectedPortfolioType = "";
  String orderBy = "likes";
  bool isDescending = true;
  final techStackToColorMap = {
    "Flutter": Colors.lightBlue,
    "React": Colors.blue.shade900,
    "Angular": Colors.red,
    "HTML/CSS": Colors.black
  };

  final filterTechStacks = ["All", "Angular", "Flutter", "HTML/CSS", "NextJS", "React"];
  final techStacks = ["Angular", "Flutter", "HTML/CSS", "NextJS", "React"];
  final filterDeveloperType = [
    "All",
    "Backend",
    "Frontend",
    "Fullstack",
    "Mobile"
  ];
  final developerType = ["Backend", "Frontend", "Fullstack", "Mobile"];
  final formKey = GlobalKey<FormState>();
  List<Map<String,dynamic>> portfolios = [];
  String searchQuery = "";
  List<dynamic> myLikes = [];
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
          selectedDevType = developerType[0];
    selectedPortfolioType = techStacks[0];
    });
  }

  void getStorage()  {
    // myLikes = await storage.getItem('likes') ?? [];
    // print("$myLikes, INITTT");
   
    myLikes = box.get('likes') ?? [];
  }

 

  Future<void> saveToStorage(likeId)async {
    myLikes.add(likeId);
    box.put('likes',myLikes);
    var t = box.get('likes');
    print("$t, SETTT");
    // await storage.setItem('likes', myLikes).onError((error, stackTrace) => print(error.toString())).then((value) => print("Success"));
  }
 Future<void> removeFromStorage(likeId)async {
    myLikes.remove(likeId);
    box.put('likes',myLikes);
    // await storage.setItem('likes', myLikes).onError((error, stackTrace) => print(error.toString())).then((value) => print("Success"));
  }
  void createPortfolio () {

    final city = <String, dynamic>{
  "url": urlController.text,
  "name": nameController.text,
  "developerType": selectedDevType,
  "portfolioType": selectedPortfolioType,
  "createdAt":  DateTime.now(),
  "likes": 0,
  "likedBy":[]
};

db
    .collection("requests")
    .doc(nameController.text + selectedDevType)
    .set(city)
    .onError((e, _) => print("Error writing document: $e"));
    return ;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStorage();
    developerFiltercontroller.initSelectedItem = [0];
    portfolioTypeFiltercontroller.initSelectedItem = [0];
    sortFiltercontroller.initSelectedItem = [0];
    
  }

  bool showLoginPopup = false;

  Future<bool> likePortfolio(portfolioId, likes)async {

    //   genericLoginPopup();
    // return false;

    if(myLikes.contains(portfolioId)){
      return false;
    }
     saveToStorage(portfolioId);
    
    db.collection('portfolios').doc(portfolioId).update({"likes":likes});
    return true;
  }

  Future<dynamic> genericLoginPopup() {
    return showDialog(context: context, builder: (context){
      return AlertDialog(
content:  Container(
        child: const Text("Login Karle"),
        
      ),
      actions: [
        OutlinedButton(onPressed: (){
          Navigator.pop(context);
        }, child: const Text("Cancel")),
        OutlinedButton(onPressed: (){}, child: const Text("Login"))

      ],
      );
     
    });
  }

  Future<bool> dislikePortfolio(portfolioId, likes)async {

    if(myLikes.contains(portfolioId)){
          removeFromStorage(portfolioId);
    
          db.collection('portfolios').doc(portfolioId).update({"likes":likes});
          return true;
    }
      return false;

  }

  bool isValidUrl(String url) {
  // Regular expression to check for a valid URL
  final RegExp urlRegExp = RegExp(
    r'^(http(s)?:\/\/)?[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+(\S*)?$',
    caseSensitive: false,
    multiLine: false,
  );

  // List of prohibited domain names
  final List<String> prohibitedDomains = [
    'pornsite1.com',
    'pornsite2.com',
    'facebook.com',
    'twitter.com',
    // Add other prohibited domains as needed
  ];

  // Check if the string matches the URL pattern
  if (!urlRegExp.hasMatch(url)) {
    return false;
  }

  // Extract domain from the URL
  final Uri uri = Uri.parse(url);
  final String domain = uri.host;

  // Check if the domain is in the list of prohibited domains
  if (prohibitedDomains.contains(domain)) {
    return false;
  }

  // If the URL is valid and not from a prohibited domain, return true
  return true;
}

int selectedDevFilter = 0;
int selectedPortfolioFilter = 0;

void onChangeDevTypeFilter(val){
    print("$val , VALLL");
   setState(() {
   selectedDevFilter = val;  
   });
}

void onChangePortfolioTypeFilter(val){
 setState(() {
 selectedPortfolioFilter = val;  
 });
}

Future<List<Map<String,dynamic>>> getPortfolios()async {
  portfolios = [];
  final querySnapshot = await db.collection("portfolios").orderBy(orderBy,descending: isDescending).get();
  print("Successfully completed");
  for (var docSnapshot in querySnapshot.docs) {
    if(selectedDevFilter != 0 && selectedPortfolioFilter != 0){
      print("AAAAA");
      if(docSnapshot.data().containsValue(filterDeveloperType[selectedDevFilter]) && docSnapshot.data().containsValue(filterTechStacks[selectedPortfolioFilter])  ) {
        portfolios.add(docSnapshot.data());
      }
    }
      else if(selectedDevFilter != 0){
      print("BBBB ${developerType[selectedDevFilter]}");

        if(docSnapshot.data().containsValue(filterDeveloperType[selectedDevFilter])) {
        portfolios.add(docSnapshot.data());
      }
      }
      else if(selectedPortfolioFilter != 0){
      print("CCCCC");

        if(docSnapshot.data().containsValue(filterTechStacks[selectedPortfolioFilter])) {
        portfolios.add(docSnapshot.data());
      }
      }
      else{
        print("DDDDD");
        portfolios.add(docSnapshot.data());

      }
      
    
    //  print('${docSnapshot.id} => ${docSnapshot.data()}');
    }
    
    portfolios = portfolios.where((element) => element['name'].toString().contains(searchQuery)).toList();
    return portfolios;
}

Future<void> openPortfolio(url)async{
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
  
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return LaptopView(context);
         
          } 
          else {
           return MobileView(context);
         
          }
        },
      ),
floatingActionButton: FloatingActionButton(onPressed: (){
  // _incrementCounter();
    //  genericLoginPopup();

  showDialog(context: context, builder: (context)=>AlertDialog(
 
    backgroundColor: Colors.white,
    content: Container(
      color: Colors.transparent,
      width: 600,
      child: Form(
        
        key: formKey,child: Column(children: [
        Text("Submit Your Portfolio",style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),),
        const SizedBox(height: 50,),
          TextFormField(
            controller: urlController,
            validator: (value) {
              bool isURLValid =  value!.length > 3;
              if(!isURLValid){
                 return "Invalid URL!";
              }
              return null;
            },
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Enter your portfolio url',
    
  ),
),
const SizedBox(height: 10,),
          TextFormField(
            validator: (value){
              if(value!.length < 3){
                return "Invalid Name!";
              }
              return null;
            },
            controller: nameController,
  decoration: const InputDecoration(
    
    border: OutlineInputBorder(),
    labelText: 'Enter your name',
  ),
),
const SizedBox(height: 20,),

DropdownButtonFormField(
  
  
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'You are a...',
  ),



  
  value: 1,
  items: const [
  DropdownMenuItem(
   
    value: 2,
    child: Text("Frontend Developer")),
  DropdownMenuItem(
    value: 1,
    child: Text("Backend Developer")),
  DropdownMenuItem(
    value: 4,
    child: Text("Mobile Developer")),
  DropdownMenuItem(
    value: 3,
    child: Text("Fullstack Developer")),
  
], onChanged: (item){
    selectedDevType = developerType[item!-1];

})
      ,
      const SizedBox(height: 20,),
      DropdownButtonFormField(
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Portfolio made with',
  ),


  value: 1,
  items: const [
  DropdownMenuItem(
    value: 1,
    child: Text("Angular")),
  DropdownMenuItem(
    value: 2,
    child: Text("Flutter")),
  DropdownMenuItem(
    value: 5,
    child: Text("React")),
  DropdownMenuItem(
    value: 3,
    child: Text("HTML/CSS")),
      DropdownMenuItem(
    value: 4,
    child: Text("NextJS")),
  
], onChanged: (item){
  selectedPortfolioType = techStacks[item!-1];
})
      ,
      const SizedBox(height: 20,),
      OutlinedButton(
        
        onPressed: (){
       
                // showDialog(context: context, builder: (context){
                //   return AlertDialog(
                //     content: Container(
                //       child: Center(child: Text("Portfolio created successfully!")),
                //     ),
                //   );
                // });
    
          if(formKey.currentState!.validate()){
              if (kDebugMode) {
                print("${urlController.text} , ${nameController.text}, $selectedDevType, $selectedPortfolioType");
              }
        createPortfolio();
        Navigator.pop(context);
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          gravity: ToastGravity.CENTER,
          msg: "Portfolio created succesfully. It will be live within 6 hours.",
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          webBgColor: '#E0B0FF',
          webPosition: "center"
        
        
        );
          }

        }, child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 200,
            child: Center(child: Text("Submit Portfolio",style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),))),
        ))
      ],
      
      )
      ,),
    ),
  ));

},
child: const Icon(
  Icons.add
),),
    );
  }

  Padding LaptopView(BuildContext context) {
    return Padding(
            padding:  const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                 
                      RichText(
                        
                        text:  TextSpan(
                          children:   [
                      TextSpan(text: 'folio', style: GoogleFonts.lato(textStyle:TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 54,fontWeight: FontWeight.w900))
                          )
                    ],
                          text: 'Binge', style:GoogleFonts.lato(textStyle:const TextStyle(color: Colors.black, fontSize: 54,fontWeight: FontWeight.w900))
                          )),
                      ] 
                    ),
                    
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
 Padding(
                      padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 24, bottom: 24),
                      child: SimpleGroupedChips<int>(
                        controller: sortFiltercontroller,
                        onItemSelected: (selected){
                          String tempA = "";
                          bool tempB = false;
                          switch(selected){
                            case 0:
                              tempA = "likes";
                              tempB = true;
                            //  getPortfolios(orderBy: "likes",isDescending: true);
                              break;
                            case 1:
                              tempA = "likes";
                              tempB = true;
                             // getPortfolios(orderBy: "likes",isDescending: true);
                              break;
                            case 2:
                              tempA = "createdAt";
                              tempB = true;
                              //getPortfolios(orderBy: "createdAt",isDescending: true);
                              break;
                            case 3:
                              tempA = "createdAt";
                              tempB = false;
                             // getPortfolios(orderBy: "createdAt",isDescending: false);
                              break;

                          }
                          setState(() {
                            orderBy = tempA;
                            isDescending = tempB;
                          });
                        },
                        values: const [0, 1, 2, 3],
                        
                        chipGroupStyle: ChipGroupStyle.minimize(
                          checkedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          selectedIcon: null,
                          selectedColorItem: Theme.of(context).colorScheme.inversePrimary,
                          disabledColor: Colors.green,
                          backgroundColorItem: Colors.white,
                          itemTitleStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        itemsTitle: const [
                          "Most Likes",
                          "Trending",
                          "Newest To Oldest",
                          "Oldest to Newest",
                 
                        ],
                      ),
                    ),
                  
                   SearchBar(searchKey: searchController,onChangeText: (val){
                    if(val.length >= 3 || val.length == 0){
                    setState(() {
                      searchQuery = val;            
                    });

                    }
                   },)
                    
                    ],
                   ),

                 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                FilterListWidget(
                                  controller: developerFiltercontroller,
                                  itemsTitle: filterDeveloperType,
                                  values: const [0, 1, 2, 3, 4],
                                  listTitle: "Developer Type",
                                  onItemSelected: onChangeDevTypeFilter,
                                ),
                                FilterListWidget(
                                  controller: portfolioTypeFiltercontroller,
                                  itemsTitle: filterTechStacks,
                                  values: const [0, 1, 2, 3, 4, 5],
                                  listTitle: "Built with",
                                  onItemSelected: onChangePortfolioTypeFilter,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        Expanded(
                          child: FutureBuilder<List<Map<String,dynamic>>>(
                            future: getPortfolios(),
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return const Center(child: CircularProgressIndicator());
                              }
                              if(snapshot.connectionState == ConnectionState.done){
                                  if(snapshot.data!.length == 0){
                                      return const Center(child: Text("No Porfolios found for this filter. Why don't you create one?"),);
                                  }
 return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SingleChildScrollView(
                                  child: Container(
                                                            
                                    child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 4/3,
                                                mainAxisExtent: 400,
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 32,
                                                mainAxisSpacing: 32),
                                        itemCount: snapshot.data?.length,
                                        shrinkWrap: true,
                                        itemBuilder: (item, index) {
 
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(16.0),
                                            
                                            child: Container(
                                              //Same as `blurRadius` i guess
                                                margin: const EdgeInsets.only(bottom: 6.0),
                                                               
                                              
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              color: Colors.white,
                                               boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(0.0, 1.0), //(x,y)
                                                    blurRadius: 1.0,
                                                  ),
                                                ],
                                              ),
                                              child: Column(children: [
                                                InkWell(
                                                  onTap: () async =>{
                                                      await openPortfolio(snapshot.data![index]['url'].toString())
                                                                        
                                                  },
                                                  // child: Image(
                                                  //     height: MediaQuery.of(context).size.height * 0.3,
                                                    
                                                  //     fit: BoxFit.contain,
                                                  //     loadingBuilder:
                                                  //         (BuildContext context,
                                                  //             Widget child,
                                                  //             ImageChunkEvent?
                                                  //                 loadingProgress) {
                                                  //       if (loadingProgress == null)
                                                  //         return child;
                                                  //       return Center(
                                                  //         child:
                                                  //             CircularProgressIndicator(
                                                  //           color: Colors.red,
                                                  //           value: loadingProgress
                                                  //                       .expectedTotalBytes !=
                                                  //                   null
                                                  //               ? loadingProgress
                                                  //                       .cumulativeBytesLoaded /
                                                  //                   loadingProgress
                                                  //                       .expectedTotalBytes!
                                                  //               : null,
                                                  //         ),
                                                  //       );
                                                  //     },
                                                  //     image:  NetworkImage(
                                                        
                                                  //         snapshot!.data![index]['imageUrl'].toString(),
                                                          
                                                  //         )),
                                              
                                              child: CachedNetworkImage(
        imageUrl: snapshot!.data![index]['imageUrl'].toString(),
        placeholder: (context, url) => const Center(child: SizedBox(
          height: 100,
          width:100,
          child: RiveAnimation.asset("assets/loader.riv"))),
        errorWidget: (context, url, error) => const Icon(Icons.error),
     ),
                                                ),
                                                                                    
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        snapshot.data![index]['name'].toString().capitalize(),
                                                        style: GoogleFonts.lato(
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize: 24)),
                                                      ),
                                                       IconButton(
                                                        onPressed: ()async{
                                                          await openPortfolio(snapshot.data![index]['url'].toString());
                                                        },
                                                        icon:  const Icon(Icons.open_in_browser_sharp)
                                                        
                                                        )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    children: [
                                                     UpvoteContainer(snapshot: snapshot, index: index, onUpvote: likePortfolio, onDownvote: dislikePortfolio),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Chip(
                                                          
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    20.0),
                                                          ),
                                                          label:  Text(
                                                              snapshot.data?[index]['developerType'], style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal) ),),
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                        ),
                                                      ),
                                                  
                                                     
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Chip(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    20.0),
                                                          ),
                                                          label:
                                                              Text( snapshot.data?[index]['portfolioType'],style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal) ),),
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                          labelStyle: const TextStyle(
                                                              color: Colors.black),
                                                        ),
                                                      )
                                                    
                                                    ],
                                                  ),
                                                ),
                                              
                                              ]),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              );
                            
                              }
                              return Container(child: const Center(child: Text("Sorry we ran into a problem. We will be back again")),);
                             
                            }
                          ),
                        ),
          
                      
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Padding MobileView(BuildContext context) {
    return Padding(
            padding:  const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                 
                      RichText(
                        
                        text:  TextSpan(
                          children:   [
                      TextSpan(text: 'folio', style: GoogleFonts.lato(textStyle:TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontSize: 54,fontWeight: FontWeight.w900))
                          )
                    ],
                          text: 'Binge', style:GoogleFonts.lato(textStyle:const TextStyle(color: Colors.black, fontSize: 54,fontWeight: FontWeight.w900))
                          )),
                      ] 
                    ),
                          SearchBarMobile(searchKey: searchController,onChangeText: (val){
                                      if(val.length >= 3 || val.length == 0){
                                      setState(() {
                                        searchQuery = val;            
                                      });

                                      }
                                     },),
                   Padding(
                                        padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 24, bottom: 24),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SimpleGroupedChips<int>(
                                            controller: sortFiltercontroller,
                                            onItemSelected: (selected){
                                              String tempA = "";
                                              bool tempB = false;
                                              switch(selected){
                                                case 0:
                                                  tempA = "likes";
                                                  tempB = true;
                                                //  getPortfolios(orderBy: "likes",isDescending: true);
                                                  break;
                                                case 1:
                                                  tempA = "likes";
                                                  tempB = true;
                                                 // getPortfolios(orderBy: "likes",isDescending: true);
                                                  break;
                                                case 2:
                                                  tempA = "createdAt";
                                                  tempB = true;
                                                  //getPortfolios(orderBy: "createdAt",isDescending: true);
                                                  break;
                                                case 3:
                                                  tempA = "createdAt";
                                                  tempB = false;
                                                 // getPortfolios(orderBy: "createdAt",isDescending: false);
                                                  break;
                                        
                                              }
                                              setState(() {
                                                orderBy = tempA;
                                                isDescending = tempB;
                                              });
                                            },
                                            values: const [0, 1, 2, 3],
                                            
                                            chipGroupStyle: ChipGroupStyle.minimize(
                                              checkedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              selectedIcon: null,
                                              selectedColorItem: Theme.of(context).colorScheme.inversePrimary,
                                              disabledColor: Colors.green,
                                              backgroundColorItem: Colors.white,
                                              itemTitleStyle: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            itemsTitle: const [
                                              "Most Likes",
                                              "Trending",
                                              "Newest To Oldest",
                                              "Oldest to Newest",
                                                                             
                                            ],
                                          ),
                                        ),
                                      ),
                                    
                                  
                               

                 
                  
                    FutureBuilder<List<Map<String,dynamic>>>(
                      future: getPortfolios(),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(child: CircularProgressIndicator());
                        }
                        if(snapshot.connectionState == ConnectionState.done){
                            if(snapshot.data!.length == 0){
                                return const Center(child: Text("No Porfolios found for this filter. Why don't you create one?"),);
                            }
 return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            
                            child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: 4/3,
                                        crossAxisCount: 1,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16),
                                itemCount: snapshot.data?.length,
                                shrinkWrap: true,
                                itemBuilder: (item, index) {
                                 
 
                                
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Container(
                                      //Same as `blurRadius` i guess
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        color: Colors.white,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: Column(children: [
                                        Image(
                                            height: 100,
                                            width: MediaQuery.of(context).size.width * 0.8,
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.red,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            image:  NetworkImage(
                                              
                                                snapshot!.data![index]['imageUrl'].toString(),
                                                
                                                )),
 
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                snapshot.data![index]['name'].toString().capitalize(),
                                                style: GoogleFonts.lato(
                                                    textStyle:
                                                        const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                            fontSize: 24)),
                                              ),
                                               IconButton(
                                                onPressed: ()async{
                                                  await openPortfolio(snapshot.data![index]['url'].toString());
                                                },
                                                icon:  const Icon(Icons.open_in_browser_sharp)
                                                
                                                )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Row(
                                            children: [
                                             UpvoteContainer(snapshot: snapshot, index: index, onUpvote: likePortfolio, onDownvote: dislikePortfolio),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Chip(
                                                  
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  label:  Text(
                                                      snapshot.data?[index]['developerType'], style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal) ),),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                ),
                                              ),
                                          
                                             
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Chip(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  label:
                                                      Text( snapshot.data?[index]['portfolioType'],style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal) ),),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              )
                                            
                                            ],
                                          ),
                                        ),
                                      
                                      ]),
                                    ),
                                  );
                                }),
                          ),
                        );
                      
                        }
                        return Container(child: const Center(child: Text("Sorry we ran into a problem. We will be back again")),);
                       
                      }
                    ),
                  
                  ],
                
                ),
              ),
            ),
          );
  }
}

class FilterListWidget extends StatelessWidget {
  FilterListWidget(
      {super.key,
      required this.controller,
      required this.itemsTitle,
      required this.values,
      required this.listTitle,
      required this.onItemSelected
      });

  final GroupController controller;
  final List<String> itemsTitle;
  final List<int> values;
  final String listTitle;
  dynamic onItemSelected = (selected)=>{};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: 200,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          listTitle,
          style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SimpleGroupedCheckbox(
            controller: controller,
            itemsTitle: itemsTitle,
            onItemSelected: (val){
              onItemSelected(val);
            },
            values: values,
            groupStyle: GroupStyle(
                activeColor: Theme.of(context).colorScheme.inversePrimary,
                itemTitleStyle:
                    GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, color: Colors.black))),
          ),
        )
      ]),
    );
  }


}


class UpvoteContainer extends StatefulWidget {
  UpvoteContainer({super.key, required this.snapshot, required this.index, required this.onUpvote, required this.onDownvote});
  AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  Function  onUpvote = (String a, int b)=> {};
  dynamic onDownvote = () => {};
  int index;
  @override
  State<UpvoteContainer> createState() => _UpvoteContainerState();
}

class _UpvoteContainerState extends State<UpvoteContainer> {
  String postLikes = "";
  @override
  Widget build(BuildContext context) {
    postLikes = widget.snapshot.data![widget.index]['likes'].toString();
    return  StatefulBuilder(

      builder: (context, setState) {
        return Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      20),
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                            ),
                                                            child: 
                                                            Row(
                                                              children: [
                                                                IconButton(
                                                                    onPressed: () async{
                                                                      String portId = widget.snapshot.data![widget.index]['name'].toString() + widget.snapshot.data![widget.index]['developerType'].toString();
                                                                      int likes = widget.snapshot.data![widget.index]['likes'] + 1;
                                                                      bool a = await widget.onUpvote(portId, likes);
                                                                      if(a){
                                                                      setState(() {
                                                                        postLikes = likes.toString();
                                                                      });
                                                                      }
                                                                    },
                                                                    icon: const Icon(Icons
                                                                        .keyboard_arrow_up)),
                                                                Text(
                                                                  postLikes.toString(),
                                                                  style: GoogleFonts.lato(
                                                                      textStyle: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .normal,
                                                                          fontSize: 16,
                                                                          color: Colors
                                                                              .black)),
                                                                ),
                                                                IconButton(
                                                                    onPressed: ()async {
                                                                       String portId = widget.snapshot.data![widget.index]['name'].toString() + widget.snapshot.data![widget.index]['developerType'].toString();
                                                                      int likes = widget.snapshot.data![widget.index]['likes'] - 1;
                                                                      bool a = await widget.onDownvote(portId, likes);
                                                                      if(a){
                                                                      setState(() {
                                                                        postLikes = (likes + 1).toString();
                                                                      });
                                                                      }
                                                                    },
                                                                    icon: const Icon(Icons
                                                                        .keyboard_arrow_down)),
                                                              ],
                                                            ),
                                                          );
      }
    );
                                                
  }
}

  class SearchBar extends StatelessWidget {

  SearchBar(
      {super.key,
      required this.searchKey,
      required this.onChangeText,
      });

  TextEditingController searchKey = TextEditingController();
   dynamic onChangeText = (val)=>{};
  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: MediaQuery.of(context).size.width * 0.2,
      height: 70,
      padding: const EdgeInsets.all(16),
      child:  TextField(
        
        controller: searchKey,
        onChanged: (value) {
          onChangeText(value);
        },
        decoration: InputDecoration(
          labelText: 'Search by name...',
          labelStyle: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.normal), ),
          prefixIconColor: const Color(0xffe0b0ff),
          
          border: const OutlineInputBorder(
            
            borderRadius: BorderRadius.all(Radius.circular(30))
          ),
   
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

  class SearchBarMobile extends StatelessWidget {

  SearchBarMobile(
      {super.key,
      required this.searchKey,
      required this.onChangeText,
      });

  TextEditingController searchKey = TextEditingController();
   dynamic onChangeText = (val)=>{};
  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: MediaQuery.of(context).size.width * 0.7,
      height: 70,
      padding: const EdgeInsets.all(16),
      child:  TextField(
        
        controller: searchKey,
        onChanged: (value) {
          onChangeText(value);
        },
        decoration: InputDecoration(
          labelText: 'Search by name...',
          labelStyle: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.normal), ),
          prefixIconColor: const Color(0xffe0b0ff),
          
          border: const OutlineInputBorder(
            
            borderRadius: BorderRadius.all(Radius.circular(30))
          ),
   
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

extension StringExtensions on String { 
  String capitalize() { 
    return "${this[0].toUpperCase()}${this.substring(1)}"; 
  } 
} 