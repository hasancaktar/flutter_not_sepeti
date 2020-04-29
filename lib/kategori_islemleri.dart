import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

class Kategoriler extends StatefulWidget {
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler == null) {
      tumKategoriler = List<Kategori>();
      kategoriListesiniGuncelle();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategoriler"),
      ),
      body: ListView.builder(
          itemCount: tumKategoriler.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () => kategoriGuncelle(tumKategoriler[index], context),
              title: Text(tumKategoriler[index].kategoriBaslik),
              trailing: InkWell(
                child: Icon(Icons.delete),
                onTap: () => kategoriSil(tumKategoriler[index].kategoriID),
              ),
              leading: Icon(Icons.category),
            );
          }),
    );
  }

  void kategoriListesiniGuncelle() {
    databaseHelper.kategoriListesiniGetir().then((kategorileriIcerenList) {
      setState(() {
        tumKategoriler = kategorileriIcerenList;
      });
    });
  }
  kategoriSil(int kategoriID) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Kategori Sil"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                    "Kategoriyi sildiğinizde bununla ilgili tüm notlar da silinecektir!"),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Vazgeç"),
                    ),
                    FlatButton(
                      onPressed: () {
                        databaseHelper
                            .kategoriSil(kategoriID)
                            .then((silinenKategori) {
                          if (silinenKategori != 0) {
                            setState(() {
                              kategoriListesiniGuncelle();
                              Navigator.pop(context);
                            });
                          }
                        });
                      },
                      child: Text(
                        "Kategoriyi Sil",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  kategoriGuncelle(Kategori guncellenecekKategori, BuildContext c) {
    kategoriGuncelleDialog(c, guncellenecekKategori);
  }

  void kategoriGuncelleDialog(
      BuildContext myContext, Kategori guncellenecekKategori) {
    var formKey = GlobalKey<FormState>();
    String guncellenecekKategoriAdi;

    showDialog(
        barrierDismissible: false,
        context: myContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Güncelle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: formKey,
                    child: TextFormField(
                      initialValue: guncellenecekKategori.kategoriBaslik,
                      onSaved: (yeniDeger) {
                        guncellenecekKategoriAdi = yeniDeger;
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
                            .kategoriGuncelle(Kategori.withID(
                                guncellenecekKategori.kategoriID,
                                guncellenecekKategoriAdi))
                            .then((katID) {
                          if (katID != 0) {

                            Scaffold.of(myContext).showSnackBar(SnackBar(
                              content: Text("Kategori Güncellendi"),
                              duration: Duration(seconds: 1),

                            ));
                            kategoriListesiniGuncelle();
                            Navigator.pop(context);
                          }
                        });
                        /*databaseHelper
                            .kategoriEkle(Kategori(guncellenecekKategoriAdi))
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("Kategori eklendi"),
                              duration: Duration(seconds: 2),
                            ));
                            Navigator.pop(context);
                          }
                        });*/
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
}
