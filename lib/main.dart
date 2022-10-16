import 'dart:ui';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'Post_Model.dart';
import 'adminlogin.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((val) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Symbex',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: landingPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _controller = ScrollController();
  DateTime prebackpress = DateTime.now();

  Future<List<posts>> _getPosts() async {
    var url = Uri.parse("https://register.symbexbd.com/api/productList");
    var data = await http.get(url);
    var jsonData = json.decode(data.body);
    List<posts> post = [];
    for (var u in jsonData) {
      posts Post = posts(
          u["product"].toString(), u["selling_price"], u["qty"].toString());
      post.add(Post);
    }

    return post;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(widget.title),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => landingPage()),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: searchdata());
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: _getPosts(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Padding(
                  padding: const EdgeInsets.all(100.0),
                  child: Center(
                    child: Text(
                      "Wait While Loading Data...",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ));
            } else {


              return DraggableScrollbar.arrows(
                heightScrollThumb: 100,
                alwaysVisibleScrollThumb: false,
                backgroundColor: Colors.black,
                controller: _controller,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  controller: _controller,
                  itemBuilder: (BuildContext context, int Index) {
                    print(snapshot.data.length.toString() + "dip");

                    return Row(
                      children: [
                        Expanded(
                          child: Container(

                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("lib/images/fg529.png"),
                                  fit: BoxFit.cover),
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(8.0),

                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[Index].product,
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 3,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Price: TK.' +
                                        NumberFormat.currency(
                                                decimalDigits: 2,
                                                locale: "en-in")
                                            .format(int.parse(snapshot
                                                .data[Index].selling_price
                                                .toString()
                                                .replaceAll(".00", '')
                                        )
                                        )
                                            .replaceAll("INR", ""),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                if (snapshot.data[Index].qty == '0')
                                  Text('Stock Running Out',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      )),
                                if (snapshot.data[Index].qty != '0')
                                  Text('Stock Available',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('*Price Based On Cash',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class landingPage extends StatefulWidget {
  @override
  State<landingPage> createState() => _landingPageState();
}

class _landingPageState extends State<landingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/images/main.png"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Positioned(
                  top: MediaQuery.of(context).size.height * .8,
                  child: Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    transitionDuration: Duration(seconds: 1),
                                    transitionsBuilder: (context, animation,
                                        anmationtime, child) {
                                      animation = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeIn);
                                      return ScaleTransition(
                                        alignment: Alignment.center,
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    pageBuilder:
                                        (context, animation, animationtime) {
                                      return logIn();
                                    }));
                          },
                          child: Text('log in as Admin'),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.lightGreen))),
                    ],
                  )),
              Positioned(
                top: MediaQuery.of(context).size.height * .85,
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  transitionDuration: Duration(seconds: 1),
                                  transitionsBuilder: (context, animation,
                                      anmationtime, child) {
                                    animation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeIn);
                                    return ScaleTransition(
                                      alignment: Alignment.center,
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                                  pageBuilder:
                                      (context, animation, animationtime) {
                                    return MyHomePage(title: "Symbex");
                                  }));
                        },
                        child: Text('Please Click For Products'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.lightGreen))),
                  ],
                ),
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height * .9,
                  child: Row(
                    children: [buttontocall()],
                  )),
              Positioned(
                child: Row(
                  children: [
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              Text("@2022 Designed and Developed by SymbexIT",style:TextStyle(color: Colors.black,letterSpacing: 1),),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class buttontocall extends StatelessWidget {
  const buttontocall({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await FlutterPhoneDirectCaller.callNumber('01796587031');
        },
        child: Text(
          'Call : 01796587031',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ));
  }
}

class posts {
  final String product;
  final String selling_price;
  final String qty;

  posts(this.product, this.selling_price, this.qty);
}

class searchdata extends SearchDelegate<Future<Widget>> {
  ScrollController _controller = ScrollController();
  Future<List<PostModel>> _getrresult({String? query}) async {
    var url = Uri.parse("https://register.symbexbd.com/api/productList");
    var data = await http.get(url);
    var jsonData = json.decode(data.body);
    final list = jsonData as List<dynamic>;
    return list
        .map((e) => PostModel.fromJson(e))
        .where((element) =>
            element.product!.toLowerCase().contains(query!.toLowerCase()))
        .toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: Colors.blueAccent,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: "Symbex")),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff191826),
      body: Container(
        child: FutureBuilder(
          future: _getrresult(query: query),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Padding(
                padding: const EdgeInsets.all(100.0),
                child: Container(
                    child: Center(
                  child: Text(
                    "Wait....",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                )),
              );
            } else {
              return DraggableScrollbar.arrows(
                heightScrollThumb: 100,
                alwaysVisibleScrollThumb: false,
                backgroundColor: Colors.black,
                controller: _controller,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  controller: _controller,
                  itemBuilder: (BuildContext context, int Index) {
                    print(snapshot.data.length.toString() + "dip");

                    return Row(
                      children: [
                        Expanded(
                          child: Container(

                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("lib/images/fg529.png"),
                                  fit: BoxFit.cover),
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(8.0),

                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[Index].product,
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 3,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Price: TK.' +
                                        NumberFormat.currency(
                                            decimalDigits: 2,
                                            locale: "en-in")
                                            .format(int.parse(snapshot
                                            .data[Index].sellingPrice
                                            .toString()
                                            .replaceAll(".00", '')
                                        )
                                        )
                                            .replaceAll("INR", ""),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                if (snapshot.data[Index].qty == '0')
                                  Text('Stock Running Out',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      )),
                                if (snapshot.data[Index].qty != '0')
                                  Text('Stock Available',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('*Price Based On Cash',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff191826),
      body: Container(
        child: FutureBuilder(
          future: _getrresult(query: query),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Padding(
                padding: const EdgeInsets.all(100.0),
                child: Container(
                    child: Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )),
              );
            } else {
              return DraggableScrollbar.arrows(
                heightScrollThumb: 100,
                alwaysVisibleScrollThumb: false,
                backgroundColor: Colors.black,
                controller: _controller,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  controller: _controller,
                  itemBuilder: (BuildContext context, int Index) {
                    print(snapshot.data.length.toString() + "dip");

                    return Row(
                      children: [
                        Expanded(
                          child: Container(

                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("lib/images/fg529.png"),
                                  fit: BoxFit.cover),
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(8.0),

                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[Index].product,
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 3,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Price: TK.' +
                                        NumberFormat.currency(
                                            decimalDigits: 2,
                                            locale: "en-in")
                                            .format(int.parse(snapshot
                                            .data[Index].sellingPrice
                                            .toString()
                                            .replaceAll(".00", '')
                                        )
                                        )
                                            .replaceAll("INR", ""),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                if (snapshot.data[Index].qty == '0')
                                  Text('Stock Running Out',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      )),
                                if (snapshot.data[Index].qty != '0')
                                  Text('Stock Available',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('*Price Based On Cash',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
