import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hacker_amiibos/components/link_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

const String SIGNUP_MUTATION = '''
  mutation SignupMutation(
    \$email: String!
    \$username: String!
    \$password: String!
  ) {
    createUser(
      email: \$email,
      username: \$username,
      password: \$password
    ) {
      user {
        id
        username
        email
      }
    }
  }
''';

const String LOGIN_MUTATION = '''
  mutation LoginMutation(
    \$username: String!,
    \$password: String!
  ) {
    tokenAuth(username: \$username, password: \$password) {
      token
    }
  }
''';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _login = true;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_login ? 'Login' : 'Sign Up'),
        // Agrega un botón en la barra de navegación que te lleve de vuelta a LinkListScreen
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LinkListScreen()), // Navegar a la pantalla de inicio de sesión
              );           
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Mutation(
          options: MutationOptions(
            document: gql(_login ? LOGIN_MUTATION : SIGNUP_MUTATION),
            onCompleted: (dynamic resultData) async {
              if (resultData != null && resultData['tokenAuth'] != null) {
                String? token = resultData['tokenAuth']['token'];
                if (token != null) {
                  await _storeAuthToken(token);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LinkListScreen()),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Authentication failed: Token is null';
                  });
                }
              } else {
                setState(() {
                  _errorMessage = 'Authentication failed: Invalid username or password';
                });
              }
            },
            onError: (OperationException? error) {
              setState(() {
                _errorMessage = 'Authentication failed: ${error?.graphqlErrors[0].message ?? 'Unknown error'}';
              });
            },
          ),
          builder: (RunMutation runMutation, QueryResult? result) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_login)
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo electrónico';
                        }
                        return null;
                      },
                    ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre de usuario';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final username = _usernameController.text;
                        final password = _passwordController.text;
                        if (_login) {
                          runMutation({
                            'username': username,
                            'password': password,
                          });
                        } else {
                          final email = _emailController.text;
                          runMutation({
                            'email': email,
                            'username': username,
                            'password': password,
                          });
                        }
                      }
                    },
                    child: Text(_login ? 'Login' : 'Create Account'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _login = !_login;
                      });
                    },
                    child: Text(_login ? 'Need to create an account?' : 'Already have an account?'),
                  ),
                  
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Función para almacenar el token de autenticación
  Future<void> _storeAuthToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AUTH_TOKEN, token);
  }
}
