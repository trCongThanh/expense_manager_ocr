import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hive/hive.dart';
import '../dashboard/main_screen.dart'; // Lấy provider theme

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  bool _isProcessing = false;
  File? _imageFile;
  
  // Dữ liệu trích xuất thủ công
  String _storeName = 'Không xác định';
  String _totalPrice = '0 đ';
  List<String> _rawLines = [];

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

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
          _rawLines = [];
          _storeName = 'Không xác định';
          _totalPrice = '0 đ';
        });
        
        await _processImageMLKit();
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImageMLKit() async {
    if (_imageFile == null) return;

    if (kIsWeb) {
      setState(() {
        _rawLines = ['Nội Dung Quét không hỗ trợ trên Web'];
        _isProcessing = false;
      });
      return;
    }

    try {
      final inputImage = InputImage.fromFile(_imageFile!);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      _parseTextLogic(recognizedText.text);
      
    } catch (e) {
      setState(() {
        _rawLines = ['Lỗi đọc ảnh: $e'];
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _parseTextLogic(String rawText) {
    if (rawText.trim().isEmpty) {
      _rawLines = ['Không tìm thấy chữ nào trong ảnh'];
      return;
    }

    final lines = rawText.split('\n');
    final priceRegex = RegExp(r'\b\d{1,3}(?:[.,]\d{3})+\b|\b\d{4,}\b');
    final storeKeywords = [
      'store', 'coffee', 'highland', 'circle k', 'shopee', 
      'mart', 'supermarket', 'coop', 'bách hóa', 'vinmart', 'winmart', 'ministop', 'familymart'
    ];

    int maxPrice = 0;
    String? foundStore;
    List<String> validLines = [];

    for (var line in lines) {
      final text = line.trim();
      if (text.isEmpty) continue;
      validLines.add(text);
      
      // Tìm tên cửa hàng
      final lowerLine = text.toLowerCase();
      if (foundStore == null) {
        for (var kw in storeKeywords) {
          if (lowerLine.contains(kw)) {
            foundStore = text;
            break;
          }
        }
      }

      // Tìm giá tiền lớn nhất
      final matches = priceRegex.allMatches(text);
      for (var match in matches) {
        final priceStr = match.group(0)!;
        // Chuẩn hóa số (xóa chấm, phẩy) để so sánh
        final cleanStr = priceStr.replaceAll('.', '').replaceAll(',', '');
        final price = int.tryParse(cleanStr);
        if (price != null && price > maxPrice) {
          maxPrice = price;
        }
      }
    }

    // Format lại giá tiền lớn nhất (thêm dấu chấm phân cách hàng nghìn)
    String formattedPrice = maxPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.'
    );

    setState(() {
      _rawLines = validLines;
      _storeName = foundStore ?? 'Không xác định';
      _totalPrice = maxPrice > 0 ? '$formattedPrice đ' : '0 đ';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ref.watch(lightModeProvider);
    final textScale = ref.watch(textSizeProvider);
    final bgColor = isLight ? Colors.white : const Color(0xFF12141C);
    final panelColor = isLight ? Colors.grey[100]! : const Color(0xFF1E1F25);
    final textColor = isLight ? Colors.black : Colors.white;
    final appBarColor = isLight ? Colors.white : const Color(0xFF12141C);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: BackButton(color: textColor), // Đảm bảo luôn có nút Trở về
        title: Text('Scan', style: TextStyle(fontSize: 20 * textScale, color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.imagePlus, color: textColor),
            onPressed: () => _pickImage(ImageSource.gallery),
          )
        ],
      ),
      body: SlidingUpPanel(
        minHeight: 280,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: panelColor,
        panel: _buildPanel(isLight, textScale, textColor),
        body: _buildBody(textColor, textScale),
      ),
    );
  }

  Widget _buildBody(Color textColor, double textScale) {
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
                      const Icon(LucideIcons.scanLine, size: 80, color: Color(0xFF8E8E93)),
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
                        label: Text('Mở Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * textScale)),
                      ),
                      const SizedBox(height: 160),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(bool isLight, double textScale, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isLight ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // --- KẾT QUẢ PHÂN TÍCH CHÍNH ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: _buildResultBox('Cửa hàng', _storeName, LucideIcons.store, isLight, textScale, textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultBox('Tổng tiền', _totalPrice, LucideIcons.banknote, isLight, textScale, textColor, isHighlight: true),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Nội Dung Quét',
            style: TextStyle(
              color: const Color(0xFF00E676),
              fontSize: 16 * textScale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // --- NỘI DUNG RAW ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isProcessing 
              ? _buildSkeletonizerLoading(isLight, textColor) 
              : _buildRawTextList(isLight, textColor, textScale),
          ),
        ),

        // --- NÚT LƯU GIAO DỊCH ---
        if (_totalPrice != '0 đ' && !_isProcessing)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Thêm vào danh sách Giao dịch
                  ref.read(transactionsProvider.notifier).update((state) {
                    final newState = [
                      {
                        'title': _storeName,
                        'category': 'Khác', 
                        'date': 'Vừa xong',
                        'amount': '-$_totalPrice',
                        'iconName': 'receipt',
                        'icon': LucideIcons.receipt,
                      },
                      ...state,
                    ];
                    // Lưu xuống ổ cứng
                    Hive.box('app_data').put('transactions', newState.map((e) => {
                      'title': e['title'],
                      'category': e['category'],
                      'date': e['date'],
                      'amount': e['amount'],
                      'iconName': e['iconName'],
                    }).toList());
                    
                    return newState;
                  });
                  
                  // Hiển thị thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu giao dịch thành công!'),
                      backgroundColor: Color(0xFF00E676),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Trở về Dashboard
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: const Color(0xFF12141C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(LucideIcons.save),
                label: Text('Lưu Hóa Đơn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * textScale)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultBox(String label, String value, IconData icon, bool isLight, double textScale, Color textColor, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF00E676).withOpacity(0.1) : (isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(16),
        border: isHighlight ? Border.all(color: const Color(0xFF00E676).withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: isHighlight ? const Color(0xFF00E676) : Colors.grey),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: Colors.grey, fontSize: 12 * textScale)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value, 
            style: TextStyle(
              color: isHighlight ? const Color(0xFF00E676) : textColor, 
              fontSize: 15 * textScale, 
              fontWeight: FontWeight.bold
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonizerLoading(bool isLight, Color textColor) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(LucideIcons.fileText, color: textColor),
              title: Text('Đang trích xuất dữ liệu...', style: TextStyle(color: textColor)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRawTextList(bool isLight, Color textColor, double textScale) {
    if (_rawLines.isEmpty) {
      return Center(
        child: Text('Chưa có Nội Dung Quét', style: TextStyle(color: Colors.grey, fontSize: 14 * textScale)),
      );
    }
    
    return ListView.builder(
      itemCount: _rawLines.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _rawLines[index],
            style: TextStyle(color: textColor, fontSize: 14 * textScale),
          ),
        );
      },
    );
  }
}
