// import 'product.dart';
// // import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// class ProductsRepository {
//   // List<Product> products = ProductsRepository.loadProducts();
//   // List<String> getURL = [];
//   // Future<List<String>> downloadURLExample() async {
//   //   for (int i = 0; i < products.length; i++) {
//   //     String downloadURL = await firebase_storage.FirebaseStorage.instance
//   //         .ref()
//   //         .child('images')
//   //         .child(products[i].image)
//   //         .getDownloadURL();
//   //     getURL[i] = downloadURL;
//   //   }
//   //   return getURL;
//   // }

//   static List<Product> loadProducts() {
//     // List<String> productURL = downloadURLExample();

//     const allProducts = <Product>[
//       Product(
//         id: 0,
//         name: 'Dragnet',
//         price: 290,
//         image: 'Dragnet.jpg',
//         // url: downloadURLExample(0),
//       ),
//       Product(
//         id: 1,
//         name: 'Bob',
//         price: 280,
//         image: 'Bob.jpg',
//         //url: "",
//       ),
//       Product(
//         id: 2,
//         name: 'Clapton',
//         price: 320,
//         image: 'Clapton.jpg',
//         //url: "",
//       ),
//       Product(
//         id: 3,
//         name: 'Hazzard',
//         price: 380,
//         image: 'Hazzard.jpg',
//         //url: "",
//       ),
//       Product(
//         id: 4,
//         name: 'Lassie',
//         price: 240,
//         image: 'Lassie.jpg',
//         //url: "",
//       ),
//       Product(
//         id: 5,
//         name: 'Hawaii-Five-O',
//         price: 180,
//         image: 'HawaiiFiveO.jpg',
//         //url: "",
//       ),
//       Product(
//         id: 6,
//         name: 'Leland',
//         price: 240,
//         image: 'Leland.jpg',
//         //url: "",
//       ),
//       Product(
//         id: 7,
//         name: 'Lou',
//         price: 180,
//         image: 'Lou.jpg',
//         //url: "",
//       ),
//       Product(
//         id: 8,
//         name: 'Roy',
//         price: 320,
//         image: 'Roy.jpg',
//         //url: "",
//       ),
//     ];

//     return allProducts;
//   }
// }
