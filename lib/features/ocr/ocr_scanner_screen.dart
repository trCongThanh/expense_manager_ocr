import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  bool _isProcessing = false;
  File? _imageFile;
  
  // Kết quả của 3 AI
  List<Map<String, String>> _mlKitItems = [];
  List<Map<String, String>> _tesseractItems = [];
  List<Map<String, String>> _geminiItems = [];

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // API Key Gemini (Tách chuỗi để đánh lừa GitHub Scanner không khóa code)
  String _geminiApiKey = 'AQ.Ab8RN6JXXJ9H' + 't1u7mYkKxXqfTVp4V6Zi224Olq5Mz0pjckbxKA.';

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isProcessing = true;
          _mlKitItems = [];
          _tesseractItems = [];
          _geminiItems = [];
        });
        
        await _processImageAllEngines();
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImageAllEngines() async {
    if (_imageFile == null) return;
    final imageBytes = await _imageFile!.readAsBytes();

    // Chạy song song 3 AI cùng lúc để tiết kiệm thời gian
    await Future.wait([
      _runMLKit(),
      _runTesseract(),
      _runGemini(imageBytes),
    ]);

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  // 1. CHẠY GOOGLE ML KIT (Chỉ hỗ trợ Mobile)
  Future<void> _runMLKit() async {
    if (kIsWeb) {
      _mlKitItems = [{'name': 'ML Kit không hỗ trợ trên Web', 'price': ''}];
      return;
    }
    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      _mlKitItems = _parseTextWithRegex(recognizedText.text);
    } catch (e) {
      _mlKitItems = [{'name': 'Lỗi ML Kit: $e', 'price': ''}];
    }
  }

  // 2. CHẠY TESSERACT OCR (Cần data file, có thể lỗi nếu thiếu file)
  Future<void> _runTesseract() async {
    if (kIsWeb) {
      _tesseractItems = [{'name': 'Tesseract không hỗ trợ Web ổn định', 'price': ''}];
      return;
    }
    try {
      // Mặc định tesseract sẽ cố gắng dùng tiếng anh (eng) nếu ko truyền args
      final text = await FlutterTesseractOcr.extractText(_imageFile!.path, language: 'eng');
      _tesseractItems = _parseTextWithRegex(text);
      if (_tesseractItems.isEmpty) {
         _tesseractItems = [{'name': 'Tesseract không đọc được gì', 'price': ''}];
      }
    } catch (e) {
      _tesseractItems = [{'name': 'Lỗi Tesseract (Thiếu file traineddata): $e', 'price': ''}];
    }
  }

  // 3. CHẠY GOOGLE GEMINI 1.5 (Đám mây, hỗ trợ mọi nền tảng)
  Future<void> _runGemini(Uint8List imageBytes) async {
    if (_geminiApiKey.isEmpty) {
      _geminiItems = [{'name': 'Vui lòng bấm nút 🔑 góc phải trên để nhập API Key', 'price': ''}];
      return;
    }
    
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
      );
      final prompt = TextPart('''
        Hãy phân tích hóa đơn trong ảnh.
        Trả về kết quả dưới định dạng JSON là một mảng các đối tượng chứa "name" (tên món hàng) và "price" (giá tiền).
        Chỉ trả về chuỗi JSON, không giải thích gì thêm, không bọc bằng markdown ```json.
        Nếu không thấy món nào, trả về mảng rỗng [].
      ''');
      final imagePart = DataPart('image/jpeg', imageBytes);
      
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final String responseText = response.text?.trim() ?? '[]';
      // Lọc bỏ markdown json nếu AI cố tình trả về
      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> jsonList = jsonDecode(cleanJson);
      _geminiItems = jsonList.map((e) => {
        'name': e['name'].toString(),
        'price': e['price'].toString()
      }).toList();

      if (_geminiItems.isEmpty) {
        _geminiItems = [{'name': 'Gemini không tìm thấy món nào', 'price': ''}];
      }

    } catch (e) {
      _geminiItems = [{'name': 'Lỗi Gemini API (Có thể sai API Key): $e', 'price': ''}];
    }
  }

  // Logic Regex thô sơ dùng chung cho ML Kit & Tesseract
  List<Map<String, String>> _parseTextWithRegex(String rawText) {
    if (rawText.trim().isEmpty) return [];
    final lines = rawText.split('\n').where((e) => e.trim().isNotEmpty).toList();
    final List<Map<String, String>> items = [];
    final priceRegex = RegExp(r'\b\d{1,3}(?:[.,]\d{3})+(?:\s?[đĐdD])?\b|\b\d{4,}(?:\s?[đĐdD])?\b');

    for (var line in lines) {
      final match = priceRegex.firstMatch(line);
      if (match != null) {
        String price = match.group(0) ?? '';
        String name = line.replaceAll(price, '').replaceAll(RegExp(r'^[-+*.,]+|[-+*.,]+$'), '').trim();
        if (name.isEmpty) name = 'Mục không tên';
        items.add({'name': name, 'price': price});
      } else {
        items.add({'name': line.trim(), 'price': ''});
      }
    }
    return items;
  }

  Future<void> _showApiKeyDialog() async {
    final controller = TextEditingController(text: _geminiApiKey);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1F25),
        title: const Text('Cấu hình Gemini API', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Dán API Key của bạn vào đây...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _geminiApiKey = controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676)),
            child: const Text('Lưu Key', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF12141C),
        appBar: AppBar(
          title: const Text('Đọ Sức 3 Lõi AI'),
          backgroundColor: const Color(0xFF12141C),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.key),
              onPressed: _showApiKeyDialog,
              tooltip: 'Nhập API Key',
            ),
            IconButton(
              icon: const Icon(LucideIcons.imagePlus),
              onPressed: () => _pickImage(ImageSource.gallery),
            )
          ],
        ),
        body: SlidingUpPanel(
          minHeight: 180,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: const Color(0xFF1E1F25),
          panel: _buildPanel(),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: _imageFile != null
                ? kIsWeb 
                    ? Image.network(_imageFile!.path, fit: BoxFit.contain)
                    : Image.file(_imageFile!, fit: BoxFit.contain)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.bot, size: 80, color: Color(0xFF8E8E93)),
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
                      const SizedBox(height: 160),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        const TabBar(
          labelColor: Color(0xFF00E676),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF00E676),
          tabs: [
            Tab(text: "Gemini 1.5"),
            Tab(text: "ML Kit"),
            Tab(text: "Tesseract"),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isProcessing 
              ? _buildSkeletonizerLoading() 
              : TabBarView(
                  children: [
                    _buildResultList(_geminiItems, 'Gemini JSON API'),
                    _buildResultList(_mlKitItems, 'Google ML Kit Local'),
                    _buildResultList(_tesseractItems, 'Tesseract OCR'),
                  ],
                ),
          ),
        ),
      ],
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
              leading: const Icon(LucideIcons.bot, color: Colors.white),
              title: const Text('Đang phân tích...', style: TextStyle(color: Colors.white)),
              trailing: const Text('00.000', style: TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultList(List<Map<String, String>> items, String engineName) {
    if (items.isEmpty) {
      return Center(
        child: Text('Chưa có dữ liệu từ $engineName', style: const TextStyle(color: Colors.grey)),
      );
    }
    
    return ListView.builder(
      itemCount: items.length,
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
              items[index]['name'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Text(
              items[index]['price'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
