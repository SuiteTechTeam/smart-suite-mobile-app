import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // Para File
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sweetmanager/ResourceManagement/models/typereport.dart';
import 'package:sweetmanager/ResourceManagement/services/typesreportservice.dart';
import 'package:sweetmanager/ResourceManagement/services/reportservice.dart';
import 'package:path_provider/path_provider.dart'; // Para almacenamiento local

class AddReport extends StatefulWidget {
  const AddReport({super.key});

  @override
  State<AddReport> createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController adminController = TextEditingController();
  final TextEditingController workerController = TextEditingController();
  ImagePicker imagePicker = ImagePicker();

  XFile? pickedFile;
  String imageurl = '';
  int? selectedTypeReportId;
  List<TypesReport> typesReports = [];
  late TypesReportService typesReportService;
  late ReportService reportService;

  @override
  void initState() {
    super.initState();
    typesReportService = TypesReportService();
    reportService = ReportService();
    fetchTypesReports();
  }

  // Obtener el directorio local donde se guardarán las imágenes
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Guardar la imagen localmente
  Future<File> _saveImageLocally(XFile imageFile) async {
    final localPath = await _getLocalPath();
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedFile = File('$localPath/$fileName');
    return await File(imageFile.path).copy(savedFile.path);
  }

  // Método para seleccionar la imagen
  Future<void> selectFile() async {
    final XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    try {
      setState(() {
        pickedFile = file; // Asignamos el archivo seleccionado
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File "${pickedFile!.name}" selected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  // Método para enviar el reporte
  Future<void> _submitReport() async {
    if (titleController.text.isEmpty ||
        contentController.text.isEmpty ||
        selectedTypeReportId == null ||
        pickedFile == null ||
        adminController.text.isEmpty ||
        workerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required, including the file.')),
      );
      return;
    }

    try {
      // Subir la imagen a Firebase Storage y obtener la URL
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      final referenceRoot = FirebaseStorage.instance.ref();
      final referenceDirImages = referenceRoot.child('images');
      final referenceImageToUpload = referenceDirImages.child(uniqueFileName);

      await referenceImageToUpload.putFile(File(pickedFile!.path));

      imageurl = await referenceImageToUpload.getDownloadURL();

      // Guardar la imagen localmente
      final localFile = await _saveImageLocally(pickedFile!);

      // Notificar que se guardó localmente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved locally at: ${localFile.path}')),
      );

      // Preparar los datos del reporte
      final reportData = {
        'typesReportsId': selectedTypeReportId,
        'adminsId': int.parse(adminController.text),
        'workersId': int.parse(workerController.text),
        'title': titleController.text,
        'description': contentController.text,
        'fileUrl': imageurl, // Guardamos la URL de la imagen subida
      };

      // Enviar el reporte
      final response = await reportService.createReport(reportData, null);

      if (response == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.pop(context, true); // Pasamos `true` para indicar éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FReport submitted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted successfully')),
      );
      Navigator.pop(context, false);
    }
  }

  Future<void> fetchTypesReports() async {
    try {
      List<TypesReport> fetchedReports = await typesReportService.fetchTypesReports();
      setState(() {
        typesReports = fetchedReports;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching report types')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Create Report',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              typesReports.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      value: selectedTypeReportId,
                      items: typesReports.map((TypesReport reportType) {
                        return DropdownMenuItem<int>(
                          value: reportType.id,
                          child: Text(reportType.title),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedTypeReportId = newValue;
                        });
                      },
                      hint: const Text('Select report type'),
                    ),
              const SizedBox(height: 8),
              _buildTextField('Admin ID', adminController),
              _buildTextField('Worker ID', workerController),
              _buildTextField('Title', titleController),
              _buildTextField('Content', contentController, isMultiline: true),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: selectFile,
                    child: const Text('Select File'),
                  ),
                ],
              ),
              if (pickedFile != null) Text("Selected: ${pickedFile!.name}"),
              Center(
                child: ElevatedButton(
                  onPressed: _submitReport,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
