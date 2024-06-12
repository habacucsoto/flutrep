import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.orange,
      child: FutureBuilder<String?>(
        future: _getAuthToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            final authToken = snapshot.data;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text(
                        'Hacker News',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text(
                        'new',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('|', style: TextStyle(color: Colors.black)),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.go('/search'),
                      child: Text(
                        'search',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    if (authToken != null) ...[
                      SizedBox(width: 8),
                      Text('|', style: TextStyle(color: Colors.black)),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.go('/create'),
                        child: Text(
                          'submit',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ],
                ),
                if (authToken != null)
                  GestureDetector(
                    onTap: () => _logout(context),
                    child: Text(
                      'logout',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'login',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(AUTH_TOKEN);
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AUTH_TOKEN);
    context.go('/');
  }
}
