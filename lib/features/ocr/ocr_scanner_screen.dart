import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  bool _isProcessing = false;
  File? _imageFile;
  String _extractedText = '';
  List<Map<String, String>> _parsedItems = [];

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  // Hàm chọn ảnh từ thư viện (Gallery) hoặc Camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isProcessing = true;
          _parsedItems = []; // Reset dữ liệu cũ
        });
        
        await _processImage();
      }
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh: $e");
      setState(() => _isProcessing = false);
    }
  }

  // Hàm xử lý OCR bằng Google ML Kit
  Future<void> _processImage() async {
    if (_imageFile == null) return;

    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      setState(() {
        _extractedText = recognizedText.text;
      });

      _parseTextToItems(_extractedText);

    } catch (e) {
      debugPrint("Lỗi OCR: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Hàm phân tích Text thô thành Danh sách món hàng
  void _parseTextToItems(String rawText) {
    if (rawText.trim().isEmpty) {
      setState(() {
        _parsedItems = [{'name': 'Không nhận diện được chữ nào từ ảnh này', 'price': ''}];
      });
      return;
    }

    final lines = rawText.split('\n').where((e) => e.trim().isNotEmpty).toList();
    final List<Map<String, String>> items = [];
    
    // Regex tìm giá tiền (ví dụ: 10.000, 25,000, 10000, 25.000đ)
    final priceRegex = RegExp(r'\b\d{1,3}(?:[.,]\d{3})+(?:\s?[đĐdD])?\b|\b\d{4,}(?:\s?[đĐdD])?\b');

    for (var line in lines) {
      final match = priceRegex.firstMatch(line);
      if (match != null) {
        // Tách giá tiền ra khỏi tên món
        String price = match.group(0) ?? '';
        String name = line.replaceAll(price, '').trim();
        
        // Dọn dẹp ký tự thừa
        name = name.replaceAll(RegExp(r'^[-+*.,]+|[-+*.,]+$'), '').trim();
        if (name.isEmpty) name = 'Mục không tên';
        
        items.add({
          'name': name, 
          'price': price
        });
      } else {
        // Nếu dòng không chứa giá tiền, vẫn in ra để người dùng biết OCR đã quét được những gì
        items.add({
          'name': line.trim(),
          'price': ''
        });
      }
    }

    setState(() {
      _parsedItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12141C),
      appBar: AppBar(
        title: const Text('Quét Hóa Đơn'),
        backgroundColor: const Color(0xFF12141C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.imagePlus),
            onPressed: () => _pickImage(ImageSource.gallery), // Nút chọn từ thư viện
          )
        ],
      ),
      body: SlidingUpPanel(
        minHeight: 120,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: const Color(0xFF1E1F25), // Màu panel nền tối
        panel: _buildPanel(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.contain)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.scan, size: 80, color: Color(0xFF8E8E93)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: const Color(0xFF12141C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(LucideIcons.camera),
                        label: const Text('Mở Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(LucideIcons.image, color: Colors.white),
                        label: const Text('Chọn ảnh từ Thư viện', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 160), // Khoảng trống cho panel
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Kết Quả Nhận Diện',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isProcessing 
              ? _buildSkeletonizerLoading() 
              : (_parsedItems.isEmpty 
                  ? const Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey))) 
                  : _buildResultList()),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonizerLoading() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(LucideIcons.shoppingBag, color: Colors.white),
              title: Text('Dòng text số ${index + 1} đang được OCR đọc...', style: const TextStyle(color: Colors.white)),
              trailing: const Text('00.000 đ', style: TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultList() {
    return ListView.builder(
      itemCount: _parsedItems.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(LucideIcons.checkCircle2, color: Color(0xFF00E676)),
            title: Text(
              _parsedItems[index]['name']!,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Text(
              _parsedItems[index]['price']!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
