import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/features/auth/data/auth_repository_impl.dart';
import 'package:pscommunitymobileapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:pscommunitymobileapp/features/auth/presentation/controllers/login_controller.dart';

class PsCommunityApp extends StatefulWidget {
  final LoginController? loginController;

  const PsCommunityApp({super.key, this.loginController});

  @override
  State<PsCommunityApp> createState() => _PsCommunityAppState();
}

class _PsCommunityAppState extends State<PsCommunityApp> {
  late final ApiClient? _apiClient;
  late final LoginController _loginController;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.loginController == null;

    if (_ownsController) {
      _apiClient = ApiClient();
      final repository = AuthRepositoryImpl(_apiClient!);
      _loginController = LoginController(LoginUseCase(repository));
    } else {
      _apiClient = null;
      _loginController = widget.loginController!;
    }

    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>(force: true);
    }
    Get.put<LoginController>(_loginController, permanent: _ownsController);
  }

  @override
  void dispose() {
    if (_ownsController) {
      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>(force: true);
      }
      _apiClient?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PS Community',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: AppRouter.login,
      routes: AppRouter.routes,
    );
  }
}
