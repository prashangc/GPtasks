import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/features/scatterplot/presentation/ui/plot_screen.dart';
import 'package:flutterfirebaseposts/features/svglayer/presentation/ui/svg_layer_screen.dart';
import 'package:flutterfirebaseposts/providers/comment_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/announcement_ui.dart';

class PostsMain extends StatelessWidget {
  const PostsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<CommentProvider>(context),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Announcements'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              )
            ],
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => PlotScreen()));
                },
                child: Text("Scatter Plot"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SvgLayerScreen()));
                },
                child: Text("SVG Layers"),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                const SizedBox(height: 8),
                Consumer<CommentProvider>(
                    builder: (context, commentProvider, child) {
                  if (commentProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return AnnouncementUI(
                    announcementModel: commentProvider.announcementModel,
                  );
                }),
              ]),
            ),
          ),
        );
      }),
    );
  }
}
