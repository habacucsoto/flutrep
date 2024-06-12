import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences
import 'constants/constants.dart';
import 'components/link_list.dart'; // Importar LinkListScreen
import 'components/create_link.dart'; // Importar CreateLinkScreen
import 'components/login.dart'; // Importar LoginScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegurar que los widgets están inicializados

  // Inicializar Hive para Flutter
  await initHiveForFlutter();

  // Inicializar SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final HttpLink httpLink = HttpLink('http://34.82.201.226:8080/graphql/');

  final AuthLink authLink = AuthLink(
    // Obtener el token de SharedPreferences
    getToken: () async => 'JWT ${prefs.getString(AUTH_TOKEN) ?? ''}', // Usar SharedPreferences
  );

  final Link link = authLink.concat(httpLink);

  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  MyApp({required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp.router(
        title: 'Flutter App',
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => LinkListScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (BuildContext context, GoRouterState state) => CreateLinkScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => LoginScreen(),
    ),
  ],
);
