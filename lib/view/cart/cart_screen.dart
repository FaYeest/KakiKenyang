// import 'package:flutter/material.dart';

// import 'package:intl/intl.dart';
// import 'package:kakikenyang/utils/colors.dart';
// import 'package:kakikenyang/utils/text_styles.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final List<Map<String, dynamic>> _cartItems = [
//     {
//       'name': 'Cilok Bandung',
//       'price': 12000,
//       'qty': 2,
//       'image': 'assets/images/jajanan1.jpg',
//     },
//     {
//       'name': 'Es Teh Manis',
//       'price': 5000,
//       'qty': 1,
//       'image': 'assets/images/jajanan2.jpg',
//     },
//   ];

//   int get totalPrice => _cartItems.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));
//   final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Keranjang'),
//         centerTitle: true,
//       ),
//       body: _cartItems.isEmpty
//           ? Center(child: Text('Keranjang kosong', style: AppTextStyles.body16))
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.separated(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _cartItems.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) {
//                       final item = _cartItems[index];
//                       return Card(
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         child: ListTile(
//                           leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.asset(
//                               item['image'],
//                               width: 48,
//                               height: 48,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) => Container(
//                                 width: 48,
//                                 height: 48,
//                                 color: Colors.grey[200],
//                                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                               ),
//                             ),
//                           ),
//                           title: Text(item['name'], style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.bold)),
//                           subtitle: Text('${_currencyFormat.format(item['price'])} x ${item['qty']}'),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.remove_circle_outline),
//                                 onPressed: () {
//                                   setState(() {
//                                     if (item['qty'] > 1) {
//                                       item['qty']--;
//                                     } else {
//                                       _cartItems.removeAt(index);
//                                     }
//                                   });
//                                 },
//                               ),
//                               Text('${item['qty']}'),
//                               IconButton(
//                                 icon: const Icon(Icons.add_circle_outline),
//                                 onPressed: () {
//                                   setState(() {
//                                     item['qty']++;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 6)],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Total', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.bold)),
//                       Text(_currencyFormat.format(totalPrice), style: AppTextStyles.body16.copyWith(color: Colors.orange, fontWeight: FontWeight.bold)),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: buttonColor,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onPressed: () {
//                           // TODO: Implementasi checkout
//                         },
//                         child: const Text('Checkout', style: TextStyle(color: Colors.white),),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
