import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtra/model/tramodel.dart';

class FirebaseFunctionfecth {
  Future<void> addTranslationPair(TranslationPairmodel pair) async {
    // final DocumentReference loccationDocument = FirebaseFirestore.instance
    //         .collection('location')
    //         .doc(FirebaseAuth.instance.currentUser!.email);
    // DocumentSnapshot locationsnapshot = await loccationDocument.get();
    //  await teacherDocument.update({
    //     'parcel': FieldValue.arrayUnion([ma]),
    //   });
    await FirebaseFirestore.instance
        .collection('translations')
        .doc('tra')
        .update({
      'col': FieldValue.arrayUnion([pair.toMap()])
    });
  }

  Future<List<TranslationPairmodel>> fetchTranslationPairs() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('translations')
        .doc('tra')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<TranslationPairmodel> translations =
          (data['col'] as List).map((entry) {
        return TranslationPairmodel.fromMap(entry as Map<String, dynamic>);
      }).toList();

      // Assuming `pair` is the new TranslationPairmodel you want to add
      // await FirebaseFirestore.instance
      //     .collection('translations')
      //     .doc('tra')
      //     .update({
      //   'col': FieldValue.arrayUnion([pair.toMap()])
      // });

      return translations;
    } else {
      return [];
    }

    // QuerySnapshot snapshot =
    //     await FirebaseFirestore.instance.collection('translations')
    //     .doc('tra').get();
    // return snapshot.docs
    //     .map((doc) =>
    //         TranslationPairmodel.fromMap(doc.data() as Map<String, dynamic>))
    //     .toList();
  }
}
