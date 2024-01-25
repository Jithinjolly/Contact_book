import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactBook extends StatefulWidget {
  const ContactBook({Key? key}) : super(key: key);

  @override
  ContactBookState createState() => ContactBookState();
}

class ContactBookState extends State<ContactBook> {
  TextEditingController contactname = TextEditingController();
  TextEditingController contactno = TextEditingController();
  TextEditingController editcontactname = TextEditingController();
  TextEditingController editcontactno = TextEditingController();
  List contactdetails = [];
  List filteredContactList = [];
  String? errornumber;
  String? errorname;

  @override
  void initState() {
    super.initState();
    contactinfos();
  }

  void contactinfos() async {
    contactdetails = await getdata();
    if (contactdetails.isNotEmpty) {
      setState(() {
        filteredContactList = List.from(contactdetails);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          'خياط شباب مشرف',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context, delegate: ContactSearch(contactdetails));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                child: SizedBox(
                  height: size.height / 3,
                  width: size.width - 40,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                          controller: contactname,
                          validator: (value) => errorname,
                          onChanged: (value) => validatename(value),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: "Contact Name",
                            errorText: errorname,
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) => errornumber,
                          controller: contactno,
                          onChanged: (value) => validateno(value),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: "Contact Number",
                            errorText: errornumber,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          onPressed: () {
                            if (contactname.text.isNotEmpty &&
                                contactno.text.isNotEmpty) {
                              if (contactno.text.isNumericOnly) {
                                savedata(contactname.text, contactno.text);
                              }
                            }
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 2,
                width: size.width - 40,
                child: Card(
                  child: filteredContactList.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredContactList.length,
                          itemBuilder: (context, index) {
                            filteredContactList.sort(
                              (a, b) => a["Name"].compareTo(b["Name"]),
                            );

                            var name = filteredContactList[index]["Name"];
                            var number = filteredContactList[index]["mobileno"];
                            return GestureDetector(
                              onLongPress: () {
                                editdialog(name, number, index);
                              },
                              child: ExpansionTile(
                                leading: const Icon(Icons.person),
                                title: Text(name),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(number),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(child: Text("No Data to show")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  savedata(String name, String number) async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? encodedMap = [];
    Map<String, dynamic> selectedTimes = {
      "Name": name.replaceFirst(name[0], name[0].toUpperCase()),
      "mobileno": number
    };
    String newdcontactinfo = json.encode(selectedTimes);
    if (kDebugMode) {
      print(newdcontactinfo);
    }
    if (prefs.containsKey("Contactinfo")) {
      encodedMap = prefs.getStringList('Contactinfo');
      encodedMap!.add(newdcontactinfo);

      prefs.setStringList('Contactinfo', encodedMap);
    } else {
      encodedMap.add(newdcontactinfo);

      prefs.setStringList('Contactinfo', encodedMap);
    }
    setState(() {
      contactname.clear();
      contactno.clear();
      contactinfos();
    });
  }

  Future<List> getdata() async {
    List<String>? encodedMap = [];
    List<Map>? contactdetailslist = [];
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("Contactinfo")) {
      encodedMap = prefs.getStringList('Contactinfo');
      for (var element in encodedMap!) {
        Map<String, dynamic> decodedMap = json.decode(element);
        if (kDebugMode) {
          print(decodedMap);
        }
        if (decodedMap.isNotEmpty) {
          contactdetailslist.add(decodedMap);
        }
      }
      return contactdetailslist;
    }
    return contactdetailslist;
  }

  editdialog(String contactname, String contactno, int index) {
    editcontactname.text = contactname;
    editcontactno.text = contactno;
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        var readOnly = true;
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                IconButton.filled(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Colors.transparent,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.purple,
                  ),
                ),
                IconButton.filled(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Colors.transparent,
                    ),
                  ),
                  onPressed: () {
                    if (editcontactname.text.isNotEmpty &&
                        editcontactno.text.isNotEmpty) {
                      editdata(
                        editcontactname.text,
                        editcontactno.text,
                        index,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.done,
                    color: Colors.purple,
                  ),
                ),
              ],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Edit Info",
                  ),
                  IconButton.filled(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent,
                      ),
                    ),
                    onPressed: () {
                      deletealert(context, contactname, contactno);
                    },
                    icon: const Icon(
                      Icons.delete_outline_sharp,
                      color: Colors.purple,
                    ),
                  ),
                  IconButton.filled(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent,
                      ),
                    ),
                    onPressed: () {
                      readOnly = false;
                      setStateSB(() {});
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              content: Column(
                children: [
                  TextField(
                    controller: editcontactname,
                    readOnly: readOnly,
                  ),
                  TextField(
                    controller: editcontactno,
                    readOnly: readOnly,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  deletealert(BuildContext context, String contactname, String contactno) {
    return showAdaptiveDialog(
      context: context,
      builder: (contextt) {
        return AlertDialog(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    Navigator.pop(context);
                  },
                );
                delete(contactname, contactno, context);
              },
              icon: const Text("yes"),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Text("no"),
            ),
          ],
          title: const Text("Do you wish to delete this contact?"),
        );
      },
    );
  }

  delete(String contactname, String contactno, context) async {
    List<String>? contactdetails = [];
    var prefs = await SharedPreferences.getInstance();
    contactdetails = prefs.getStringList("Contactinfo");
    var index = contactdetails!.indexWhere((element) {
      var elements = json.decode(element);
      return elements["Name"] == contactname;
    });
    contactdetails.removeAt(index);
    if (contactdetails.isNotEmpty) {
      prefs.setStringList('Contactinfo', contactdetails);
      Navigator.pop(context);
      setState(() {
        contactinfos();
      });
    } else {
      prefs.remove("Contactinfo");

      Navigator.pop(context);

      setState(() {
        contactinfos();
      });
    }
  }

  validateno(String number) {
    if (!number.isNumericOnly) {
      errornumber = "Please enter number only";
    } else {
      errornumber = null;
    }
    setState(() {});
  }

  validatename(String name) {
    if (name.isNumericOnly) {
      errorname = "Please enter Name only";
    } else {
      errorname = null;
    }
    setState(() {});
  }

  editdata(String name, String number, int index) async {
    var prefs = await SharedPreferences.getInstance();

    List<String>? contactdetails = [];
    Map<String, dynamic> contactinfo = {
      "Name": name.replaceFirst(name[0], name[0].toUpperCase()),
      "mobileno": number
    };
    String newdcontactinfo = json.encode(contactinfo);
    if (kDebugMode) {
      print(newdcontactinfo);
    }
    if (prefs.containsKey("Contactinfo")) {
      contactdetails = prefs.getStringList('Contactinfo');
      contactdetails?.removeAt(index);
      contactdetails!.insert(index, newdcontactinfo);

      prefs.setStringList('Contactinfo', contactdetails);
    }
    setState(() {
      Navigator.pop(context);
      contactinfos();
    });
  }
}

class ContactSearch extends SearchDelegate<String> {
  final List<dynamic> contactList;

  ContactSearch(this.contactList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(query);
  }

  Widget buildSearchResults(String query) {
    List<dynamic> searchResults = [];

    if (query.isEmpty) {
      searchResults = List.from(contactList);
    } else {
      searchResults = contactList
          .where((contact) =>
              contact["Name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        var name = searchResults[index]["Name"];
        var number = searchResults[index]["mobileno"];
        return GestureDetector(
          onLongPress: () {
            // Handle long press
          },
          child: ExpansionTile(
            leading: const Icon(Icons.person),
            title: Text(name),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(number),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  bool get isNumericOnly {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }
}

void showAdaptiveDialog(
    {required BuildContext context, required WidgetBuilder builder}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return builder(context);
    },
  );
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactBook(),
    ),
  );
}
