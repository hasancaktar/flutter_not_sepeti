import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/main.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID;
  int secilenOncelik;
  String notBaslik, notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategorileriIcerenMapListesi) {
      for (Map okunanMap in kategorileriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }
      if (widget.duzenlenecekNot != null) {
        kategoriID = widget.duzenlenecekNot.kategoriID;
        secilenOncelik = widget.duzenlenecekNot.notOncelik;
      } else {
        kategoriID = 1;
        secilenOncelik = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(widget.baslik),
        ),
        body: tumKategoriler.length <= 0
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Kategori: ",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  items: kategoriItemleriOlustur(),
                                  value: kategoriID,
                                  onChanged: (secilenKategoriID) {
                                    setState(() {
                                      kategoriID = secilenKategoriID;
                                    });
                                  }),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 18),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.duzenlenecekNot != null
                              ? widget.duzenlenecekNot.notBaslik
                              : "",
                          validator: (text) {
                            if (text.length < 3) {
                              return "En az 3 karakter olmalı";
                            }
                            return null;
                          },
                          onSaved: (text) {
                            notBaslik = text;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Not başlığını girin",
                              labelText: "Başlık"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          initialValue: widget.duzenlenecekNot != null
                              ? widget.duzenlenecekNot.notIcerik
                              : "",
                          onSaved: (text) {
                            notIcerik = text;
                          },
                          maxLines: 4,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Not içeriğini girin",
                              labelText: "İçerik"),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Öncelik: ",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  items: _oncelik.map((oncelik) {
                                    return DropdownMenuItem<int>(
                                      child: Text(
                                        oncelik,
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      value: _oncelik.indexOf(oncelik),
                                    );
                                  }).toList(),
                                  value: secilenOncelik,
                                  onChanged: (secilenOncelikID) {
                                    setState(() {
                                      secilenOncelik = secilenOncelikID;
                                    });
                                  }),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 18),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          )
                        ],
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Vazgeç"),
                            color: Colors.grey,
                          ),
                          RaisedButton(
                            onPressed: () {
                              if (formKey.currentState.validate()) {
                                formKey.currentState.save();
                                var suan = DateTime.now();
                                if (widget.duzenlenecekNot == null) {
                                  databaseHelper
                                      .notEkle(Not(
                                    kategoriID,
                                    notBaslik,
                                    notIcerik,
                                    suan.toString(),
                                    secilenOncelik,
                                  ))
                                      .then((kaydedilenNotID) {
                                    if (kaydedilenNotID != 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                } else {
                                  databaseHelper
                                      .notGuncelle(Not.withID(
                                    widget.duzenlenecekNot.notID,
                                    kategoriID,
                                    notBaslik,
                                    notIcerik,
                                    suan.toString(),
                                    secilenOncelik,
                                  )).then((guncellenenID) {
                                    if (guncellenenID != 0) {
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              }
                            },
                            child: Text("Kaydet"),
                            color: Colors.red.shade700,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ));
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Text(
                kategori.kategoriBaslik,
                style: TextStyle(fontSize: 30),
              ),
            ))
        .toList();
  }
}
/*
Form(
        child: Column(
          children: <Widget>[
            Center(
              child: tumKtegoriler.length <= 0
                  ? CircularProgressIndicator()
                  : Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 48),
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                        value: kategoriID,
                        items: kategoriItemleriOlustur(),
                        onChanged: (secilenKategoriID) {
                          setState(() {
                            kategoriID = secilenKategoriID;
                          });
                        },
                      )),
                    ),
            )
          ],
        ),
      )
 */
