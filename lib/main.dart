import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/registration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login.dart';
import 'screens/sidebar.dart';
import 'screens/create_bug.dart';
import 'bugsList.dart';
import 'temp.dart';
import 'screens/appBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        // Set your desired text direction here
        textDirection: TextDirection.ltr, // Or TextDirection.rtl
        child: Scaffold(
          body: user != null ? ImageUploader() : LoginScreen(),
        ),
      ),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key? key, this.user}) : super(key: key);
  User? user = FirebaseAuth.instance.currentUser;
  var userInfo;
  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  // late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void getCurrentUserDetails() async {
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user?.email)
            .get();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user?.email)
        .get()
        .then((value) {
      setState(() {
        widget.userInfo = value;
      });
    });
    // if (userSnapshot.exists) {
    //   print("User snapshot ${userSnapshot['username']}");
    // }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
    // _model = createModel(context, () => HomePageModel());
    //print(widget.user);
  }

  @override
  void dispose() {
    // _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        drawer: bgz_drawer(userInfo: widget.userInfo),
        appBar: AppBarNav(
          goToHomePage: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePageWidget(
                        user: widget.user,
                      )),
            );
          },
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "All bugs",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 15),
              Expanded(
                child: Container(
                  child: BugsListScreen(
                    user: widget.user,
                    contextType: "All",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
