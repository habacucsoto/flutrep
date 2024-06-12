import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'login.dart'; // Importar el archivo de la pantalla de inicio de sesión
import 'create_link.dart'; // Importar la pantalla para crear un nuevo enlace

const String FEED_QUERY = '''
  query {
        links {
          id
          answer
          link
          postedBy {
            username
          }
          votes {
            id
          }
        }
      }
''';

const String VOTE_MUTATION = '''
  mutation VoteMutation(\$linkId: Int!) {
    createVote(
      linkId: \$linkId
    ) {
      link {
        id
        votes {
          id
        }
      }
    }
  }
''';


class LinkListScreen extends StatefulWidget {
  @override
  _LinkListScreenState createState() => _LinkListScreenState();
}

class _LinkListScreenState extends State<LinkListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hackeryesno'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateLinkScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(FEED_QUERY),
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          List links = result.data?['links'] ?? [];

          return ListView.builder(
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        child: Image.network(
                          link['link'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link['answer'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('Answer: ${link['answer']}'),
                            Text('ID: ${link['id']}'),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Posted by: ${link['postedBy'] != null ? link['postedBy']['username'] ?? 'unknown' : 'unknown'}'),
                                Mutation(
                                  options: MutationOptions(
                                    document: gql(VOTE_MUTATION),
                                    onCompleted: (dynamic resultData) {
                                      // Refetch the query to get the updated vote count
                                      refetch?.call();
                                    },
                                  ),
                                  builder: (RunMutation runMutation, QueryResult? result) {
                                    int votesCount = link['votes'].length;
                                    return Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.thumb_up, size: 16),
                                          onPressed: () {
                                            runMutation({'linkId': link['id']});
                                            setState(() {
                                              votesCount += 1;
                                            });
                                          },
                                        ),
                                        SizedBox(width: 5),
                                        Text('$votesCount'),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}