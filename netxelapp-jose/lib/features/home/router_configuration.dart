import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netxelapp/features/auth/presentation/pages/login_page.dart';
import 'package:netxelapp/features/auth/presentation/pages/send_invitation_link.dart';
import 'package:netxelapp/features/auth/presentation/pages/signup_page.dart';
import 'package:netxelapp/features/auth/presentation/pages/splash_page.dart';
import 'package:netxelapp/features/home/factory.dart';
import 'package:netxelapp/features/home/home.dart';
import 'package:netxelapp/features/home/layout.dart';
import 'package:netxelapp/features/home/pages/categorias%20de%20gastos/expenses_categories_page.dart';
import 'package:netxelapp/features/home/pages/components/lists/categoria_list.dart';
import 'package:netxelapp/features/home/pages/components/lists/empleado_list.dart';
import 'package:netxelapp/features/home/pages/components/lists/insumo_list.dart';
import 'package:netxelapp/features/home/pages/components/lists/medida_list.dart';
import 'package:netxelapp/features/home/pages/components/lists/producto_list.dart';
import 'package:netxelapp/features/home/pages/components/lists/proveedor_list.dart';
import 'package:netxelapp/features/home/pages/components/lists/receta_list.dart';
import 'package:netxelapp/features/home/pages/gastos/expenses_page.dart';
import 'package:netxelapp/features/home/pages/production/production_page.dart';
import 'package:netxelapp/features/home/pages/puchases/puchase_page.dart';
import 'package:netxelapp/features/home/pages/recipes/recipes_view.dart';
import 'package:netxelapp/features/home/pages/sales/sales_history_screen.dart';
import 'package:netxelapp/features/home/pages/sales/sales_page.dart';
import 'package:netxelapp/features/home/pages/stocks/products/product_stock.dart';
import 'package:netxelapp/features/home/pages/stocks/raw_materials/raw_material_stock_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/LoginLink',
      builder: (context, state) => const LoginPageLink(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Builder(
          builder: (BuildContext context) {
            return ShellScaffold(child: child);
          },
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Home(),
        ),
        GoRoute(
          path: '/categorias',
          builder: (context, state) => const CategoriaList(),
        ),
        GoRoute(
          path: '/medidas',
          builder: (context, state) => const MedidaList(),
        ),
        GoRoute(
          path: '/empleados',
          builder: (context, state) => const EmployeeList(),
        ),
        GoRoute(
          path: '/insumos',
          builder: (context, state) => const RawMaterialList(),
        ),
        GoRoute(
          path: '/productos',
          builder: (context, state) => const ProductoList(),
        ),
        GoRoute(
          path: '/recetas',
          builder: (context, state) => const RecetaList(),
        ),
        GoRoute(
          path: '/proveedores',
          builder: (context, state) => const ProviderList(),
        ),
        GoRoute(
          path: '/add_fabrica',
          builder: (context, state) => const NuevaFabricaPage(),
        ),
        GoRoute(
          path: '/recipes',
          builder: (context, state) => const RecipeView(),
        ),
        GoRoute(
          path: '/productstock',
          builder: (context, state) => const ProductStock(),
        ),
        GoRoute(
          path: '/rawmaterials',
          builder: (context, state) => const RawMaterialStock(),
        ),
        GoRoute(
          path: '/comprainsumos',
          builder: (context, state) => RawMaterialPurchasesPage(),
        ),
        GoRoute(
          path: '/ventashistorial',
          builder: (context, state) => const SalesHistoryScreen(),
        ),
        GoRoute(
          path: '/ventas',
          builder: (context, state) => const SalesScreen(),
        ),
        GoRoute(
          path: '/production',
          builder: (context, state) => const ProductionPage(),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ExpensesPage(),
        ),
        GoRoute(
          path: '/expensesCategories',
          builder: (context, state) => const ExpenseCategoriesPage(),
        ),
      ],
    ),
  ],
);
