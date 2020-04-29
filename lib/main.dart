import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:flutter_not_sepeti/not_detay.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';
import 'kategori_islemleri.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.red),
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.category),
                    title: Text("Kategoriler"),
                    onTap: () {
                      Navigator.pop(context);
                      _kategorilerSayfasinaGit(context);
                    },
                  ),
                )
              ];
            },
          ),
        ],
        title: Center(
          child: Text("Not Sepeti"),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "Kategori Ekle",
            onPressed: () {
              kategoriEkleDialog(context);
            },
            tooltip: "Kategori Ekle",
            mini: true,
            child: Icon(Icons.category),
          ),
          FloatingActionButton(
            heroTag: "NotEkle",
            onPressed: () => _detaySayfasinaGit(context),
            tooltip: "Not Ekle",
            child: Icon(Icons.add),
          )
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: formKey,
                    child: TextFormField(
                      onSaved: (yeniDeger) {
                        yeniKategoriAdi = yeniDeger;
                      },
                      decoration: InputDecoration(
                          labelText: "Kategori adı",
                          border: OutlineInputBorder()),
                      validator: (girilenKategoriAdi) {
                        if (girilenKategoriAdi.length < 3) {
                          return "En az 3 karakter giriniz";
                        }
                        return null;
                      },
                    )),
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.orange,
                    child:
                        Text("Vazgeç", style: TextStyle(color: Colors.white)),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .kategoriEkle(Kategori(yeniKategoriAdi))
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("Kategori eklendi"),
                              duration: Duration(seconds: 1),
                            ));
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    color: Colors.red,
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  _detaySayfasinaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Yeni Not",
                )));
  }

  _kategorilerSayfasinaGit(context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Kategoriler()));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;

  //var formKeyy=GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    super.setState(fn);
    NotListesi();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper.notListesiniGeti(),
      builder: (context, AsyncSnapshot<List<Not>> snapsShot) {
        if (snapsShot.connectionState == ConnectionState.done) {
          tumNotlar = snapsShot.data;

          return ListView.builder(
              itemCount: tumNotlar.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                  title: Text(tumNotlar[index].notBaslik),
                  subtitle: Text(tumNotlar[index].kategoriBaslik),
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Kategori ",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tumNotlar[index].kategoriBaslik,
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Oluşturulma Tarihi ",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  databaseHelper.dateFormat(DateTime.parse(
                                      tumNotlar[index].notTarih)),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "İçerik:\n" + tumNotlar[index].notIcerik,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FlatButton(
                                child: Text(
                                  "Sil",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                onPressed: () =>
                                    _notSil(tumNotlar[index].notID),
                              ),
                              FlatButton(
                                child: Text("Güncelle",
                                    style: TextStyle(color: Colors.green)),
                                onPressed: () {
                                  _detaySayfasinaGit(context, tumNotlar[index]);
                                  setState(() {});
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _detaySayfasinaGit(BuildContext context, Not not) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Notu Düzenle",
                  duzenlenecekNot: not,
                )));
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text(
            "Az",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade100,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "Orta",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade200,
        );

        break;
      case 2:
        return CircleAvatar(
          child: Text(
            "Çok",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade700,
        );

        break;
    }
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 1),
          content: Text("Not Silindi"),
        ));
        setState(() {});
      }
    });
  }
}
