import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'Post_Model.dart';
import 'main.dart';
import 'package:intl/intl.dart';

class adminhome extends StatefulWidget {
  @override
  State<adminhome> createState() => _adminhome();
}

class _adminhome extends State<adminhome> {
  ScrollController _controller = ScrollController();

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

  Future<bool?> showWarnig(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Do You Want To Exit "),
          actions: [
            ElevatedButton(
              child: Text("No"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: Text("Yes"),
              onPressed: () => SystemNavigator.pop(),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final sholdpop = await showWarnig(context);
        return sholdpop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text("Symbex"),
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
        body: FutureBuilder(
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
                            padding: const EdgeInsets.all(10.0),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[Index].product,
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Price : TK.' +
                                        NumberFormat.currency(
                                                decimalDigits: 2,
                                                locale: "en-in")
                                            .format(int.parse(snapshot
                                                .data[Index].selling_price))
                                            .replaceAll("INR", ""),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    'Qunatity : ' +
                                        snapshot.data[Index].qty +
                                        " Nos",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                if (snapshot.data[Index].qty == '0' ||
                                    snapshot.data[Index].qty == '1' ||
                                    snapshot.data[Index].qty == '2' ||
                                    snapshot.data[Index].qty == '3')
                                  (Text('Low on Stock',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ))),
                                SizedBox(
                                  height: 10,
                                ),
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
          MaterialPageRoute(builder: (context) => adminhome()),
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
                    "Wait...",
                    style: TextStyle(color: Colors.white),
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
                            padding: const EdgeInsets.all(10.0),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[Index].product,
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                                .replaceAll(".00", '')))
                                            .replaceAll("INR", ""),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    'Qunatity : ' +
                                        snapshot.data[Index].qty +
                                        " Nos",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                if (snapshot.data[Index].qty == '0' ||
                                    snapshot.data[Index].qty == '1' ||
                                    snapshot.data[Index].qty == '2' ||
                                    snapshot.data[Index].qty == '3')
                                  (Text('Low on Stock',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ))),
                                SizedBox(
                                  height: 10,
                                ),
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
                    style: TextStyle(color: Colors.white, fontSize: 30),
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
                            padding: const EdgeInsets.all(10.0),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data[Index].product,
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                                .replaceAll(".00", '')))
                                            .replaceAll("INR", ""),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    'Qunatity : ' +
                                        snapshot.data[Index].qty +
                                        " Nos",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                if (snapshot.data[Index].qty == '0' ||
                                    snapshot.data[Index].qty == '1' ||
                                    snapshot.data[Index].qty == '2' ||
                                    snapshot.data[Index].qty == '3')
                                  (Text('Low on Stock',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ))),
                                SizedBox(
                                  height: 10,
                                ),
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
