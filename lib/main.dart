import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/products/product_management.dart';
import 'screens/stores/store_management.dart';
import 'screens/stocks/stock_alerts.dart';
import 'screens/stocks/stock_history.dart';
import 'screens/suppliers/supplier_management.dart';
import 'screens/orders/supplier_order_list.dart';
import 'screens/reports/reports_page.dart';
import 'screens/users/user_management.dart';
import 'screens/transfers/stock_transfer_form.dart';
import 'screens/transfers/transfer_history_page.dart';
import 'screens/sales/new_sale_page.dart';
import 'screens/sales/sales_history_page.dart';
import 'screens/sales/sales_stats_page.dart';
import 'screens/notifications/notifications_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleurs personnalisées
    const Color primaryColor = Color(0xFF2196F3);
    const Color accentColor = Color(0xFF64B5F6);
    const Color backgroundColor = Color(0xFFF5F5F5);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion de Stock',
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          background: backgroundColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: Colors.grey[800]),
          bodyMedium: TextStyle(color: Colors.grey[600]),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/products': (context) => const ProductManagementPage(),
        '/stores': (context) => const StoreManagementPage(),
        '/stocks': (context) => const StockAlertsPage(),
        '/stock-history': (context) => const StockHistoryPage(),
        '/suppliers': (context) => const SupplierManagementPage(),
        '/orders': (context) => const SupplierOrderListPage(),
        '/reports': (context) => const ReportsPage(),
        '/users': (context) => const UserManagementPage(),
        '/transfers/new': (context) => const StockTransferForm(),
        '/transfers/history': (context) => const TransferHistoryPage(),
        '/transfers/history/:id': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return TransferHistoryPage(transferIdToHighlight: args['transferId']);
        },
        '/orders/history/:id': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return SupplierOrderListPage(orderIdToHighlight: args['orderId']);
        },
        '/sales/new': (context) => const NewSalePage(),
        '/sales/history': (context) => const SalesHistoryPage(),
        '/sales/stats': (context) => const SalesStatsPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}
