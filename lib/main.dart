import 'package:customer_app/features/auth/presentation/pages/welcome_farmer/welcome_farmer.dart';
import 'package:customer_app/features/auth/presentation/pages/status/farmer_status.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:customer_app/features/home/presentation/pages/bott_navbar/bott_naav.dart' as customer_nav;
import 'package:customer_app/features/home/presentation/pages/bott_navbar/farmer_bott_naav.dart' as farmer_nav;
import 'package:customer_app/features/admin_dashboard/presentation/pages/bott_nav/bott_nav.dart' as admin_nav;
import 'package:customer_app/features/home/presentation/providers/product_provider.dart';
import 'package:customer_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer_app/features/chat/presentation/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (authProvider.isAuthenticated) {
            final user = authProvider.currentUser!;
            final role = user.role;
            final status = user.status;
            
            if (role == 'admin') {
              return const admin_nav.BottomScreen();
            } else if (role == 'farmer') {
              // Check Farmer approval status
              if (status == 'approved') {
                return const farmer_nav.FarmerBottomScreen();
              } else {
                return FarmerStatusScreen(
                   status: status,
                   onSignOut: () { authProvider.signOut(); },
                );
              }
            } else {
              // Customer side (standard 'user' role)
              return const customer_nav.BottomScreen();
            }
          }
          return const WelcomeFarmer();
        },
      ),
    );
  }
}
