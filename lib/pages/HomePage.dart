import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/servises/FireStoreService.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //fireSore Services
  final Firestoreservice firestoreservice = Firestoreservice();

  //text controller
  final TextEditingController textController = TextEditingController();

  //Dialog to get the input for the note
  void openNotesDialog({String? docId}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      //add note
                      if (docId == null) {
                        firestoreservice.addNote(textController.text);
                      } else {
                        firestoreservice.updateNote(docId, textController.text);
                      }
                      //emty text field
                      textController.clear();
                      //pop the dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
        backgroundColor: Colors.amber,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: openNotesDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreservice.getNotesStream(),
          builder: (context, snapshot) {
            //if we have data get all docs
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    //get each individual doc
                    DocumentSnapshot document = notesList[index];
                    String docId = document.id;

                    //get notes from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];
                    //display as a list tile
                    return ListTile(
                        title: Text(noteText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //update
                            IconButton(
                            onPressed: () => openNotesDialog(docId: docId),
                            icon: const Icon(Icons.edit_note_outlined),
                            ),
                            //delete
                            IconButton(
                            onPressed: () => firestoreservice.deleteNote(docId),
                            icon: const Icon(Icons.delete_forever),
                            ),

                          ],
                        )
                    );
                  });
            } else {
              return const Center(child: Text('No notes :|'));
            }
          }),
    );
  }
}
