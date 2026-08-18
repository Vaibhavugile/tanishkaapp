import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_chat_service.dart';
class AdminShipmentScreen extends StatefulWidget {
  final String orderId;

  const AdminShipmentScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminShipmentScreen> createState() =>
      _AdminShipmentScreenState();
}

class _AdminShipmentScreenState
    extends State<AdminShipmentScreen> {
  ///////////////////////////////////////////////////////////
  /// CONTROLLERS
  ///////////////////////////////////////////////////////////
final FirebaseFirestore _firestore =
    FirebaseFirestore.instance;
  ///////////////////////////////////////////////////////////
  /// CURRENT ADMIN ID
  ///////////////////////////////////////////////////////////

  String get _adminId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        "Admin is not logged in.",
      );
    }

    return user.uid;
  }

  final TextEditingController _shipmentIdController =
      TextEditingController();

  ///////////////////////////////////////////////////////////
  /// IMAGE PICKER
  ///////////////////////////////////////////////////////////

  final ImagePicker _imagePicker =
      ImagePicker();

  ///////////////////////////////////////////////////////////
  /// FIREBASE STORAGE
  ///////////////////////////////////////////////////////////

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  ///////////////////////////////////////////////////////////
  /// PACKAGE IMAGES
  ///////////////////////////////////////////////////////////

  final List<File> _packageImages = [];

  ///////////////////////////////////////////////////////////
  /// MAX PHOTOS
  ///////////////////////////////////////////////////////////

  static const int _maxPhotos = 3;

  ///////////////////////////////////////////////////////////
  /// SAVING
  ///////////////////////////////////////////////////////////

  bool _isSaving = false;

  ///////////////////////////////////////////////////////////
  /// DISPOSE
  ///////////////////////////////////////////////////////////

  @override
  void dispose() {
    _shipmentIdController.dispose();
    super.dispose();
  }

  ///////////////////////////////////////////////////////////
  /// ADD PHOTO
  ///////////////////////////////////////////////////////////

  Future<void> _addPhoto() async {
    if (_packageImages.length >=
        _maxPhotos) {
      _showError(
        "You can add maximum 3 package photos.",
      );
      return;
    }

    /////////////////////////////////////////////////////////
    /// SELECT SOURCE
    /////////////////////////////////////////////////////////

    final source =
        await _showImageSource();

    if (source == null) {
      return;
    }

    /////////////////////////////////////////////////////////
    /// PICK IMAGE
    /////////////////////////////////////////////////////////

    try {
      final XFile? picked =
          await _imagePicker.pickImage(
        source: source,

        // Initial reduction from image_picker.
        imageQuality: 85,

        // Prevent extremely large camera images.
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (picked == null) {
        return;
      }

      final file =
          File(picked.path);

      if (!file.existsSync()) {
        _showError(
          "Selected image could not be found.",
        );
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _packageImages.add(file);
      });
    } catch (e) {
      debugPrint(
        "Shipment image selection error: $e",
      );

      _showError(
        "Failed to select image.",
      );
    }
  }

  ///////////////////////////////////////////////////////////
/// SAVE SHIPMENT
///////////////////////////////////////////////////////////

Future<void> _saveShipment({
  required String shipmentId,
  required List<String> photoUrls,
}) async {
  final orderId =
      widget.orderId.trim();

  if (orderId.isEmpty) {
    throw Exception(
      "Order ID is missing.",
    );
  }

  if (shipmentId.isEmpty) {
    throw Exception(
      "Shipment ID is missing.",
    );
  }

  if (photoUrls.isEmpty) {
    throw Exception(
      "Shipment photos are missing.",
    );
  }

  /////////////////////////////////////////////////////////
  /// SHIPMENT DATA
  /////////////////////////////////////////////////////////

  final shipmentData =
      <String, dynamic>{
    "shipmentId":
        shipmentId,

    "packageImages":
        photoUrls,

    "photoCount":
        photoUrls.length,

    "status":
        "shipped",

    "createdBy":
        _adminId,

    "createdAt":
        FieldValue.serverTimestamp(),

    "updatedBy":
        _adminId,

    "updatedAt":
        FieldValue.serverTimestamp(),
  };

  /////////////////////////////////////////////////////////
  /// SAVE SHIPMENT
  ///
  /// One shipment document for this order.
  /////////////////////////////////////////////////////////

  final shipmentRef =
      _firestore
          .collection("orders")
          .doc(orderId)
          .collection("shipments")
          .doc();

  await shipmentRef.set(
    {
      ...shipmentData,

      "shipmentDocumentId":
          shipmentRef.id,
    },
  );

  /////////////////////////////////////////////////////////
  /// UPDATE ORDER
  /////////////////////////////////////////////////////////

  await _firestore
      .collection("orders")
      .doc(orderId)
      .update({
    "shipmentId":
        shipmentId,

    "shipmentStatus":
        "Shipped",

    "shipmentPhotoUrls":
        photoUrls,

    "shipmentCreatedBy":
        _adminId,

    "shipmentCreatedAt":
        FieldValue.serverTimestamp(),

    "updatedAt":
        FieldValue.serverTimestamp(),
  });
}
///////////////////////////////////////////////////////////
/// SEND SHIPMENT TO CUSTOMER CHAT
///////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////
/// SEND SHIPMENT TO CUSTOMER CHAT
///////////////////////////////////////////////////////////

Future<void> _sendShipmentToChat({
  required String shipmentId,
  required List<String> photoUrls,
}) async {
  if (widget.orderId.trim().isEmpty) {
    throw Exception(
      "Order ID is missing.",
    );
  }

  if (shipmentId.trim().isEmpty) {
    throw Exception(
      "Shipment ID is missing.",
    );
  }

  if (photoUrls.isEmpty) {
    throw Exception(
      "Shipment photos are missing.",
    );
  }

  /////////////////////////////////////////////////////////
  /// SHIPMENT DATA
  /////////////////////////////////////////////////////////

  final shipmentData =
      <String, dynamic>{
    "reportType":
        "shipment",

    "orderId":
        widget.orderId,

    "shipmentId":
        shipmentId,

    "packageImages":
        photoUrls,

    "photoCount":
        photoUrls.length,

    "status":
        "shipped",

    ///////////////////////////////////////////////////////
    /// IMPORTANT
    ///
    /// Do NOT put FieldValue.serverTimestamp()
    /// inside shipmentData here.
    ///
    /// AdminChatService itself handles
    /// createdAt using serverTimestamp.
    ///////////////////////////////////////////////////////

    "sentAt":
        DateTime.now().toIso8601String(),
  };

  /////////////////////////////////////////////////////////
  /// SEND MESSAGE
  /////////////////////////////////////////////////////////

  await AdminChatService.instance
      .sendShipmentMessage(
    orderId:
        widget.orderId,
    text:
        "Shipment dispatched",
    shipmentData:
        shipmentData,
  );
}

  ///////////////////////////////////////////////////////////
  /// IMAGE SOURCE
  ///////////////////////////////////////////////////////////

  Future<ImageSource?> _showImageSource() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.black12,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  "Add Package Photo",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                //////////////////////////////////////////////////
                /// CAMERA
                //////////////////////////////////////////////////

                ListTile(
                  leading:
                      _sourceIcon(
                    Icons.camera_alt_rounded,
                  ),
                  title:
                      const Text(
                    "Take Photo",
                  ),
                  subtitle:
                      const Text(
                    "Use camera",
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.camera,
                    );
                  },
                ),

                //////////////////////////////////////////////////
                /// GALLERY
                //////////////////////////////////////////////////

                ListTile(
                  leading:
                      _sourceIcon(
                    Icons.photo_library_rounded,
                  ),
                  title:
                      const Text(
                    "Choose from Gallery",
                  ),
                  subtitle:
                      const Text(
                    "Select package photo",
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///////////////////////////////////////////////////////////
  /// SOURCE ICON
  ///////////////////////////////////////////////////////////

  Widget _sourceIcon(
    IconData icon,
  ) {
    return Container(
      width: 42,
      height: 42,
      decoration:
          BoxDecoration(
        color:
            const Color(0xffF4EEF2),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child:
          Icon(
        icon,
        color:
            const Color(0xff241B2F),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// REMOVE PHOTO
  ///////////////////////////////////////////////////////////

  void _removePhoto(
    int index,
  ) {
    if (_isSaving) {
      return;
    }

    if (index < 0 ||
        index >=
            _packageImages.length) {
      return;
    }

    setState(() {
      _packageImages.removeAt(
        index,
      );
    });
  }

  ///////////////////////////////////////////////////////////
  /// VALIDATE
  ///////////////////////////////////////////////////////////

  bool _validate() {
    final shipmentId =
        _shipmentIdController.text
            .trim();

    /////////////////////////////////////////////////////////
    /// SHIPMENT ID
    /////////////////////////////////////////////////////////

    if (shipmentId.isEmpty) {
      _showError(
        "Please enter the shipment ID.",
      );
      return false;
    }

    /////////////////////////////////////////////////////////
    /// PHOTOS
    /////////////////////////////////////////////////////////

    if (_packageImages.isEmpty) {
      _showError(
        "Please add at least one package photo.",
      );
      return false;
    }

    /////////////////////////////////////////////////////////
    /// MAX PHOTOS
    /////////////////////////////////////////////////////////

    if (_packageImages.length >
        _maxPhotos) {
      _showError(
        "Maximum 3 package photos are allowed.",
      );
      return false;
    }

    return true;
  }

  ///////////////////////////////////////////////////////////
  /// OPTIMIZE SHIPMENT IMAGE
  ///////////////////////////////////////////////////////////

  Future<File> _optimizeShipmentImage(
    File originalFile,
    int index,
  ) async {
    if (!originalFile.existsSync()) {
      throw Exception(
        "Shipment photo $index not found.",
      );
    }

    /////////////////////////////////////////////////////////
    /// ORIGINAL SIZE
    /////////////////////////////////////////////////////////

    final originalSize =
        await originalFile.length();

    debugPrint(
      "Shipment photo $index original size: "
      "${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB",
    );

    /////////////////////////////////////////////////////////
    /// TARGET PATH
    /////////////////////////////////////////////////////////

    final directory =
        originalFile.parent;

    final targetPath =
        "${directory.path}/"
        "shipment_optimized_"
        "${DateTime.now().millisecondsSinceEpoch}_"
        "$index.jpg";

    /////////////////////////////////////////////////////////
    /// COMPRESS
    /////////////////////////////////////////////////////////

    final compressed =
        await FlutterImageCompress
            .compressAndGetFile(
      originalFile.path,
      targetPath,

      ///////////////////////////////////////////////////////
      /// MAX WIDTH / HEIGHT
      ///////////////////////////////////////////////////////

      minWidth: 1600,
      minHeight: 1600,

      ///////////////////////////////////////////////////////
      /// JPEG QUALITY
      ///////////////////////////////////////////////////////

      quality: 80,

      ///////////////////////////////////////////////////////
      /// JPEG
      ///////////////////////////////////////////////////////

      format:
          CompressFormat.jpeg,

      ///////////////////////////////////////////////////////
      /// REMOVE EXIF
      ///////////////////////////////////////////////////////

      keepExif: false,
    );

    if (compressed == null) {
      throw Exception(
        "Failed to optimize shipment photo $index.",
      );
    }

    final optimizedFile =
        File(compressed.path);

    if (!optimizedFile.existsSync()) {
      throw Exception(
        "Optimized shipment photo $index not found.",
      );
    }

    /////////////////////////////////////////////////////////
    /// OPTIMIZED SIZE
    /////////////////////////////////////////////////////////

    final optimizedSize =
        await optimizedFile.length();

    debugPrint(
      "Shipment photo $index optimized size: "
      "${(optimizedSize / 1024 / 1024).toStringAsFixed(2)} MB",
    );

    return optimizedFile;
  }

  ///////////////////////////////////////////////////////////
  /// UPLOAD PACKAGE PHOTOS
  ///////////////////////////////////////////////////////////

  Future<List<String>>
      _uploadPackagePhotos() async {
    final shipmentId =
        _shipmentIdController.text
            .trim();

    /////////////////////////////////////////////////////////
    /// VALIDATE
    /////////////////////////////////////////////////////////

    if (shipmentId.isEmpty) {
      throw Exception(
        "Shipment ID is required.",
      );
    }

    if (_packageImages.isEmpty) {
      throw Exception(
        "At least one package photo is required.",
      );
    }

    if (_packageImages.length >
        _maxPhotos) {
      throw Exception(
        "Maximum 3 package photos are allowed.",
      );
    }

    /////////////////////////////////////////////////////////
    /// URL LIST
    /////////////////////////////////////////////////////////

    final List<String>
        uploadedUrls = [];

    /////////////////////////////////////////////////////////
    /// LOOP
    /////////////////////////////////////////////////////////

    for (
      int index = 0;
      index <
          _packageImages.length;
      index++
    ) {
      ///////////////////////////////////////////////////////
      /// ORIGINAL
      ///////////////////////////////////////////////////////

      final originalFile =
          _packageImages[index];

      if (!originalFile.existsSync()) {
        throw Exception(
          "Package photo ${index + 1} "
          "was not found.",
        );
      }

      ///////////////////////////////////////////////////////
      /// OPTIMIZE
      ///////////////////////////////////////////////////////

      final optimizedFile =
          await _optimizeShipmentImage(
        originalFile,
        index + 1,
      );

      ///////////////////////////////////////////////////////
      /// STORAGE PATH
      ///////////////////////////////////////////////////////

      final storageRef =
          _storage.ref().child(
        "shipmentPhotos/"
        "${widget.orderId}/"
        "$shipmentId/"
        "package_${index + 1}.jpg",
      );

      ///////////////////////////////////////////////////////
      /// UPLOAD
      ///////////////////////////////////////////////////////

      debugPrint(
        "Uploading shipment photo "
        "${index + 1}/${_packageImages.length}",
      );

      await storageRef.putFile(
        optimizedFile,
        SettableMetadata(
          contentType:
              "image/jpeg",
          customMetadata: {
            "orderId":
                widget.orderId,
            "shipmentId":
                shipmentId,
            "photoIndex":
                "${index + 1}",
            "type":
                "shipment_package_photo",
          },
        ),
      );

      ///////////////////////////////////////////////////////
      /// DOWNLOAD URL
      ///////////////////////////////////////////////////////

      final url =
          await storageRef
              .getDownloadURL();

      uploadedUrls.add(url);

      ///////////////////////////////////////////////////////
      /// DELETE TEMP OPTIMIZED FILE
      ///////////////////////////////////////////////////////

      try {
        if (optimizedFile.path !=
            originalFile.path) {
          await optimizedFile
              .delete();
        }
      } catch (e) {
        debugPrint(
          "Could not delete temp optimized file: $e",
        );
      }
    }

    /////////////////////////////////////////////////////////
    /// RETURN
    /////////////////////////////////////////////////////////

    return uploadedUrls;
  }

  ///////////////////////////////////////////////////////////
  /// CREATE SHIPMENT
  ///
  /// STEP 2
  ///
  /// Flow:
  /// - validates
  /// - optimizes images
  /// - uploads images
  /// - saves shipment
  /// - sends shipment to customer chat
  ///////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////
/// CREATE SHIPMENT
///////////////////////////////////////////////////////////

Future<void> _createShipment() async {
  if (!_validate()) {
    return;
  }

  if (_isSaving) {
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    final shipmentId =
        _shipmentIdController.text
            .trim();

    /////////////////////////////////////////////////////////
    /// 1. UPLOAD OPTIMIZED PHOTOS
    /////////////////////////////////////////////////////////

    final photoUrls =
        await _uploadPackagePhotos();

    if (photoUrls.isEmpty) {
      throw Exception(
        "No shipment photos were uploaded.",
      );
    }

    /////////////////////////////////////////////////////////
    /// 2. SAVE SHIPMENT
    /////////////////////////////////////////////////////////

    await _saveShipment(
      shipmentId:
          shipmentId,
      photoUrls:
          photoUrls,
    );

    /////////////////////////////////////////////////////////
    /// 3. SEND TO CUSTOMER CHAT
    /////////////////////////////////////////////////////////

    await _sendShipmentToChat(
      shipmentId:
          shipmentId,
      photoUrls:
          photoUrls,
    );

    /////////////////////////////////////////////////////////
    /// SUCCESS
    /////////////////////////////////////////////////////////

    if (!mounted) {
      return;
    }

    _showSuccess(
      "Shipment created and sent to customer.",
    );

    /////////////////////////////////////////////////////////
    /// OPTIONAL CLEAR
    /////////////////////////////////////////////////////////

    setState(() {
      _shipmentIdController.clear();
      _packageImages.clear();
    });
  } catch (e) {
    debugPrint(
      "Create shipment error: $e",
    );

    if (!mounted) {
      return;
    }

    _showError(
      "Failed to create shipment: $e",
    );
  } finally {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }
}

  ///////////////////////////////////////////////////////////
  /// ERROR
  ///////////////////////////////////////////////////////////

  void _showError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            const Color(0xffB3261E),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SUCCESS
  ///////////////////////////////////////////////////////////

  void _showSuccess(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            const Color(0xff2E7D32),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFAF8F9),

      /////////////////////////////////////////////////////////
      /// APP BAR
      /////////////////////////////////////////////////////////

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xff241B2F),
        foregroundColor:
            Colors.white,
        title:
            const Text(
          "Create Shipment",
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),

      /////////////////////////////////////////////////////////
      /// BODY
      /////////////////////////////////////////////////////////

      body:
          SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              //////////////////////////////////////////////////
              /// ORDER
              //////////////////////////////////////////////////

              _buildOrderInfo(),

              const SizedBox(
                height: 18,
              ),

              //////////////////////////////////////////////////
              /// SHIPMENT DETAILS
              //////////////////////////////////////////////////

              _buildSectionTitle(
                "Shipment Details",
              ),

              const SizedBox(
                height: 9,
              ),

              _buildShipmentIdField(),

              const SizedBox(
                height: 22,
              ),

              //////////////////////////////////////////////////
              /// PACKAGE PHOTOS
              //////////////////////////////////////////////////

              _buildSectionTitle(
                "Package Photos",
              ),

              const SizedBox(
                height: 5,
              ),

              const Text(
                "Add 1–3 clear photos of the packed package.",
                style: TextStyle(
                  fontSize: 11,
                  color:
                      Color(0xff76656D),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _buildPhotoGrid(),

              const SizedBox(
                height: 28,
              ),

              //////////////////////////////////////////////////
              /// CREATE SHIPMENT
              //////////////////////////////////////////////////

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _isSaving
                          ? null
                          : _createShipment,

                  //////////////////////////////////////////////////
                  /// ICON
                  //////////////////////////////////////////////////

                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .local_shipping_rounded,
                        ),

                  //////////////////////////////////////////////////
                  /// LABEL
                  //////////////////////////////////////////////////

                  label: Text(
                    _isSaving
                        ? "Uploading..."
                        : "Create Shipment",
                  ),

                  //////////////////////////////////////////////////
                  /// STYLE
                  //////////////////////////////////////////////////

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xff241B2F,
                    ),
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        const Color(
                      0xff8A8188,
                    ),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                    textStyle:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              //////////////////////////////////////////////////
              /// INFO
              //////////////////////////////////////////////////

              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ORDER INFO
  ///////////////////////////////////////////////////////////

  Widget _buildOrderInfo() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xff241B2F),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child:
                const Icon(
              Icons.receipt_long_rounded,
              color:
                  Colors.white,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order",
                  style:
                      TextStyle(
                    color:
                        Colors.white60,
                    fontSize:
                        10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  widget.orderId,
                  maxLines:
                      1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        13,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SECTION TITLE
  ///////////////////////////////////////////////////////////

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style:
          const TextStyle(
        fontSize: 15,
        fontWeight:
            FontWeight.w900,
        color:
            Color(0xff241B2F),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SHIPMENT ID FIELD
  ///////////////////////////////////////////////////////////

  Widget _buildShipmentIdField() {
    return TextField(
      controller:
          _shipmentIdController,
      textInputAction:
          TextInputAction.done,
      enabled:
          !_isSaving,
      decoration:
          InputDecoration(
        hintText:
            "Enter shipment / tracking ID",

        prefixIcon:
            const Icon(
          Icons.qr_code_2_rounded,
        ),

        filled:
            true,

        fillColor:
            Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xffE8E0E4),
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xffE8E0E4),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xff241B2F),
            width: 1.4,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// PHOTO GRID
  ///////////////////////////////////////////////////////////

  Widget _buildPhotoGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ///////////////////////////////////////////////////////
        /// ADD PHOTO
        ///////////////////////////////////////////////////////

        if (_packageImages.length <
            _maxPhotos)
          _buildAddPhoto(),

        ///////////////////////////////////////////////////////
        /// PHOTOS
        ///////////////////////////////////////////////////////

        ...List.generate(
          _packageImages.length,
          (index) {
            return _buildPhotoCard(
              _packageImages[index],
              index,
            );
          },
        ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////
  /// ADD PHOTO
  ///////////////////////////////////////////////////////////

  Widget _buildAddPhoto() {
    return GestureDetector(
      onTap:
          _isSaving
              ? null
              : _addPhoto,

      child:
          Container(
        width: 105,
        height: 130,
        decoration:
            BoxDecoration(
          color:
              Colors.white,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border:
              Border.all(
            color:
                const Color(
              0xffDCD3D8,
            ),
            width: 1.3,
          ),
        ),
        child:
            const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .add_a_photo_rounded,
              size: 30,
              color:
                  Color(0xff241B2F),
            ),

            SizedBox(
              height: 8,
            ),

            Text(
              "Add Photo",
              style:
                  TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// PHOTO CARD
  ///////////////////////////////////////////////////////////

  Widget _buildPhotoCard(
    File file,
    int index,
  ) {
    return Stack(
      children: [
        ///////////////////////////////////////////////////////
        /// IMAGE
        ///////////////////////////////////////////////////////

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          child:
              Image.file(
            file,
            width: 105,
            height: 130,
            fit:
                BoxFit.cover,
            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                width: 105,
                height: 130,
                color:
                    const Color(
                  0xffF0ECEE,
                ),
                child:
                    const Icon(
                  Icons
                      .broken_image_outlined,
                ),
              );
            },
          ),
        ),

        ///////////////////////////////////////////////////////
        /// NUMBER
        ///////////////////////////////////////////////////////

        Positioned(
          left: 7,
          bottom: 7,
          child:
              Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.black
                      .withOpacity(
                .65,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child:
                Text(
              "${index + 1}",
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize:
                    10,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ),

        ///////////////////////////////////////////////////////
        /// REMOVE
        ///////////////////////////////////////////////////////

        Positioned(
          top: 5,
          right: 5,
          child:
              GestureDetector(
            onTap:
                _isSaving
                    ? null
                    : () {
                        _removePhoto(
                          index,
                        );
                      },
            child:
                Container(
              width: 27,
              height: 27,
              decoration:
                  const BoxDecoration(
                color:
                    Colors.white,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.close_rounded,
                size: 17,
                color:
                    Color(0xffB3261E),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////
  /// INFO CARD
  ///////////////////////////////////////////////////////////

  Widget _buildInfoCard() {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xffF4EFF2),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color:
                Color(0xff76656D),
          ),

          SizedBox(
            width: 8,
          ),

          Expanded(
            child:
                Text(
              "Package photos are optimized before "
              "being uploaded to Firebase. Add clear "
              "photos showing the complete package.",
              style:
                  TextStyle(
                fontSize: 10,
                height: 1.4,
                color:
                    Color(0xff76656D),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}