import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebaseposts/features/scatterplot/data/repo/plot_repository_impl.dart';
import 'package:flutterfirebaseposts/features/scatterplot/data/source/plot_local_datasource.dart';
import 'package:flutterfirebaseposts/features/scatterplot/domain/usecase/plot_usecase.dart';
import 'package:flutterfirebaseposts/features/scatterplot/presentation/provider/plot_provider.dart';
import 'package:flutterfirebaseposts/features/svglayer/presentation/ui/svg_layer_screen.dart';
import 'package:flutterfirebaseposts/firebase_options.dart';
import 'package:provider/provider.dart';

import 'providers/comment_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(
          create: (_) => PlotProvider(
            PlotUsecase(
              repository: PlotRepositoryImpl(PlotLocalDataSourceImpl()),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'EC Go Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: false,
        ),
        initialRoute:
            FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const ChatHomeWrapper(),
          '/svg-layer': (context) => const SvgLayerScreen(),
        },
      ),
    );
  }
}

class ChatHomeWrapper extends StatefulWidget {
  const ChatHomeWrapper({super.key});

  @override
  State<ChatHomeWrapper> createState() => _ChatHomeWrapperState();
}

class _ChatHomeWrapperState extends State<ChatHomeWrapper> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      final provider = Provider.of<CommentProvider>(context, listen: false);
      provider.fetchPostDetails();
      _started = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const PostsMain();
  }
}
