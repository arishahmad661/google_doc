import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/common/widgets/loader.dart';
import 'package:google_docs/model/document_model.dart';
import 'package:google_docs/model/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:routemaster/routemaster.dart';

import '../colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref){
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }
  void createDocument(BuildContext context ,WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);
    final errorModel = await ref.read(documentRepositoryProvider).createDocument(token);
    
    if(errorModel.data != null){
      navigator.push('/document/${errorModel.data.id}');
    }else{
      snackbar.showSnackBar(
        SnackBar(content: Text(errorModel.error!))
      );
    }
  }

  void navigateToDocument(BuildContext context, String documentId){
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: Drawer(),
        appBar: AppBar(
          bottom: PreferredSize(preferredSize: Size.fromHeight(1),child: Container(decoration: BoxDecoration(border: Border.all(color: kGrayColor, width: 0.1)),),),
          backgroundColor: kWhiteColor,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Image.asset("assets/images/docs-logo.png", height: 40,),
          ),
          actions: [
            IconButton(onPressed: (){createDocument(context, ref);}, icon: const Icon(Icons.add)),
            IconButton(onPressed: (){signOut(ref);}, icon: const Icon(Icons.logout)),
          ],
        ),
      body: FutureBuilder<ErrorModel>(
        future: ref.watch(documentRepositoryProvider).getDocument(ref.watch(userProvider)!.token),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Loader();
          }
          return Center(
            child: SizedBox(
              width: 600,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3
                ),
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  DocumentModel document = snapshot.data!.data[index];
                  return InkWell(
                    onTap: (){
                      navigateToDocument(context, document.id);
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              document.title,
                              style: TextStyle(
                              fontSize: 17
                            ),),
                          ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      )
    );
  }
}
