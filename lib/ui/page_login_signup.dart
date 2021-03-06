import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khatam_quran/quran/background/background.dart';
import 'package:khatam_quran/service/authentication.dart';
import 'package:khatam_quran/ui/google_sign_in_btn.dart';

class LoginSignupPage extends StatefulWidget {

  const LoginSignupPage({Key key, this.auth, this.onSignIn}) : super(key: key);

  final BaseAuth auth;
  final Function(FirebaseUser) onSignIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();

  double horizontalPadding = 20.0;
  bool _isLoading = false;
  String _email;
  String _password;
  String _errorMessage;
  FormMode _formMode;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Background().buildImageBackground(),
          _showBody(),
          _showCircularProgress()
        ],
      ),
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/appicon/app_icon.png'),
      ),
    );
  }

  Widget _showBody() {
    return new Container(
      alignment: Alignment.bottomCenter,
      child: new Form(
        key: _formKey,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showLogo(),
            _showAppTitle(),
            _showSubtitle(),
            Align(
              alignment: Alignment.center,
              child: Background().buildPrivacyPolicy(),
            ),
            _showErrorMessage(),
            _showEmailInput(),
            _showPasswordInput(),
            _showPrimaryButton(),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: GoogleSignInButton(
                onPressed: () => _validateAndSubmitGoogle(),
              ),
            ),
            _showSecondaryButton(),
            _showSkipLogin()
          ],
        ),
      ),
    );
  }

  Widget _showAppTitle() {
    return new Container(
      padding: EdgeInsets.only(top: 10),
      alignment: Alignment.center,
      child: new Text("Khatam Alquran",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
    );
  }

  Widget _showSubtitle(){
    return new Container(
      padding: EdgeInsets.only(top: 5),
      alignment: Alignment.center,
      child: new Text(_getTitle(),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(4283326968)),),
    );
  }

  String _getTitle() {
    switch (_formMode) {
      case (FormMode.LOGIN) :
        return 'Masuk Aplikasi';
        break;
      case (FormMode.RESET) :
        return 'Pulihkan Password';
      default :
        return 'Registrasi Akun Baru';
    }
  }

  Widget _showCircularProgress() {
    if (_isLoading != null && _isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Container(height: 0.0, width: 0.0);
    }
  }

  Widget _showEmailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: horizontalPadding, right: horizontalPadding),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email tidak boleh kosong' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _showPasswordInput() {
    if ( _formMode != FormMode.RESET ){
      return Padding(
        padding: EdgeInsets.only(top: 16.0, left: horizontalPadding, right: horizontalPadding),
        child: new TextFormField(
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: new InputDecoration(
              hintText: 'Password',
              icon: new Icon(
                Icons.lock,
                color: Colors.grey,
              )),
          validator: (value) => value.isEmpty ? 'Password tidak boleh kosong' : null,
          onSaved: (value) => _password = value,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.only(top: 25.0, left: horizontalPadding, right: horizontalPadding),
        child: new MaterialButton(
          elevation: 5.0,
          minWidth: 200.0,
          height: 42.0,
          color: Color(4283326968),
          child:
          buildPrimaryButtonText(),
          onPressed: _validateAndSubmit,
        ));
  }

  Widget _showSkipLogin() {
    return Padding(
      padding: EdgeInsets.only(top: 25),
      child: new MaterialButton(
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Color(4292665342),
        child:
        Align(
          alignment: Alignment.topRight,
          child: new Text('Masuk aplikasi tanpa daftar >',
              style: new TextStyle(fontSize: 18.0, color: Color(4283326968))),
        ),
        onPressed: _anonLogin,
      ),
    );
  }

  Widget buildPrimaryButtonText() {
    switch (_formMode) {
      case (FormMode.LOGIN) :
        return new Text('Masuk',
            style: new TextStyle(fontSize: 20.0, color: Colors.white));
        break;
      case (FormMode.RESET) :
        return new Text('Kirim',
            style: new TextStyle(fontSize: 20.0, color: Colors.white));
      default :
        return new Text('Buat akun',
            style: new TextStyle(fontSize: 20.0, color: Colors.white));
    }
  }

  _validateAndSubmit() async {
    if (_validateAndSave()) {

      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });

      String userID = "";
      try {

        switch ( _formMode ){
          case FormMode.LOGIN :
            FirebaseUser user = await widget.auth.signIn(_email, _password);
            userID = user.uid;
            print('Signed in : $userID');
            if ( userID != null && userID.isNotEmpty ){
              if (user.isEmailVerified) {
                widget.onSignIn(user);
              } else {
                _showAlert(context, "Verifikasi email dibutuhkan",
                    "Cek email untuk melakukan verifikasi");
              }
            }
            break;
          case FormMode.SIGNUP :
            await widget.auth.signUp(_email, _password);
            widget.auth.sendEmailVerification();
            _showAlert(context, "Daftar berhasil",
                "Cek email untuk melakukan verifikasi");
            print('Signed up : $userID');
            _changeFormToLogin();
            break;
          case FormMode.RESET :
            await widget.auth.sendResetEmail(_email);
            _showAlert(context, "Pemulihan berhasil", "Cek email anda untuk memulihkan password.");
            _changeFormToLogin();
            break;
        }
      } catch (e) {
        print('Error $e');
        setState(() {
          _isLoading = false;

          if ( _ios() ){
            _errorMessage = e.details;
          } else {
            _errorMessage = e.message;
          }
        });
      }
    } else {}
  }

  bool _ios(){
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Widget _showSecondaryButton() {
    return Column(
      children: <Widget>[
        new FlatButton(
            child: _formMode == FormMode.LOGIN
                ? new Text(
              'Tidak punya akun ? Buat baru',
              style:
              new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
            )
                : new Text(
              'Sudah punya akun ? Masuk',
              style:
              new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
            ),
            onPressed: _formMode == FormMode.LOGIN
                ? _changeFormToSignUp
                : _changeFormToLogin),
        new FlatButton(
            onPressed: _changeFormToForgotPassword,
            child: new Text(
                "Lupa password ?",
                style: new TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w300))
        ),
      ],
    );
  }

  _validateAndSubmitGoogle() async{
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    final onError = (exception, stacktrace) {
      setState(() {
        _errorMessage = exception.toString();
        _isLoading = false;
      });
    };

    FirebaseUser user = await widget.auth.signInGoogle(onError);
    String userID = user.uid;
    print('Signed in : $userID');
    if ( userID != null && userID.isNotEmpty ){
      widget.onSignIn(user);
    }
  }

  _anonLogin() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    String userID = "";
    try {
      FirebaseUser user = await widget.auth.signinAnon();
      userID = user.uid;
      print('Signed in : $userID');
      if (userID != null && userID.isNotEmpty) {
        widget.onSignIn(user);
      }
    } catch (e) {
      print('Error $e');
      setState(() {
        _isLoading = false;

        if (_ios()) {
          _errorMessage = e.details;
        } else {
          _errorMessage = e.message;
        }
      });
    }
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _isLoading = false;
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  Future _showAlert(BuildContext context, String title, String content) async {
    return showDialog(
        context: context,
        builder: (context){
          return new AlertDialog(
            title: new Text(title),
            content: new Text(content),
            actions: <Widget>[
              new FlatButton(onPressed: () => Navigator.pop(context), child: new Text('Ok'))
            ],
          );
        }
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 25),
        child: new Text(_errorMessage,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.bold)),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  void _changeFormToForgotPassword() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.RESET;
    });
  }

}

enum FormMode { LOGIN, SIGNUP, RESET }
