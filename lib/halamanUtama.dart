import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  _HalamanUtamaState createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late Future<dynamic> data;

  @override
  void initState() {
    super.initState();
    data = fetchData();
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  Future<dynamic> fetchData() async {
    final response = await http
        .get(Uri.parse('https://api-berita-indonesia.vercel.app/cnn/terbaru/'));

    if (response.statusCode == 200) {
      dynamic decodedData = json.decode(response.body);
      return decodedData;
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Go-SIP")),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<dynamic>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            log(snapshot.data['data'].toString());
            List<dynamic> dataList = snapshot.data['data']['posts'];

            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                var parsedDate = DateTime.parse(dataList[index]['pubDate']);
                var formattedDate = timeago.format(parsedDate, locale: 'id');
                return GestureDetector(
                  onTap: () {
                    _launcher(dataList[index]['link']);
                  },
                  child: Card(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12)
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.5,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(dataList[index]['thumbnail']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Implementasi logika favorit di sini
                                },
                                child: Icon(Icons.bookmark_outline_rounded),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text(
                              dataList[index]['title'] ?? 'Tidak ada judul'),
                          subtitle: Text(dataList[index]['description'] ??
                              'Tidak ada deskripsi'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        fixedColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (int index) {
          // Handle on tap
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: "Category",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
  Future<void> _launcher(String url) async{
    final Uri _url = Uri.parse(url);
    if(!await launchUrl(_url)){
      throw Exception("Gagal membuka url : $_url");
    }
  }
}
