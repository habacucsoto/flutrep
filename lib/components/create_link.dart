import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'link_list.dart';

const String CREATE_LINK_MUTATION = '''
  mutation PostMutation(
        \$answer: String!
        \$link: String!
    ) {
        createLink(answer: \$answer, link: \$link) {
            id
            answer
            link
        }
    }
''';

class CreateLinkScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final linkController = useTextEditingController();
    final answerController = useTextEditingController();

    final createLinkMutation = useMutation(
      MutationOptions(
        document: gql(CREATE_LINK_MUTATION),
        onCompleted: (_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LinkListScreen()),
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Link'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: answerController,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
            TextField(
              controller: linkController,
              decoration: InputDecoration(labelText: 'Link'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                createLinkMutation.runMutation({
                  'link': linkController.text,
                  'answer': answerController.text,
                });
              },
              child: Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}