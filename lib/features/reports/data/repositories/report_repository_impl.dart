import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/exceptions/app_exceptions.dart';
import '../../../threat_analysis/domain/entities/threat_analysis.dart';
import '../../../threat_analysis/domain/repositories/threat_analysis_repository.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

/// Data layer implementation of [ReportRepository].
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({
    required SupabaseClient supabaseClient,
    required ThreatAnalysisRepository threatAnalysisRepository,
  })  : _supabaseClient = supabaseClient,
        _threatAnalysisRepository = threatAnalysisRepository;

  final SupabaseClient _supabaseClient;
  final ThreatAnalysisRepository _threatAnalysisRepository;
  final _uuid = const Uuid();

  @override
  Future<Report> generateReport({
    required String analysisId,
    required String userId,
    required ReportFormat format,
  }) async {
    try {
      if (format != ReportFormat.pdf) {
        throw UnsupportedError('Only PDF format is currently supported.');
      }

      // 1. Fetch analysis data
      final analysis = await _threatAnalysisRepository.getAnalysisById(analysisId);
      if (analysis == null) {
        throw Exception('Analysis not found.');
      }

      // 2. Generate PDF document
      final pdf = pw.Document();

      // Executive Summary Page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader(analysis),
            pw.SizedBox(height: 20),
            _buildExecutiveSummary(analysis),
            pw.SizedBox(height: 20),
            _buildAssetsSection(analysis),
            pw.SizedBox(height: 20),
            _buildThreatsSection(analysis),
          ],
        ),
      );

      final bytes = await pdf.save();

      // 3. Save locally
      final dir = await getApplicationDocumentsDirectory();
      final reportId = _uuid.v4();
      final fileName = 'threat_report_$reportId.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // 4. Save metadata to Supabase
      final reportData = {
        'id': reportId,
        'analysis_id': analysisId,
        'user_id': userId,
        'title': 'Threat Report: ${analysis.systemDescription.split('\n').first.substring(0, analysis.systemDescription.length > 30 ? 30 : analysis.systemDescription.length)}...',
        'generated_at': DateTime.now().toIso8601String(),
        'format': 'pdf',
        'file_path': file.path,
        'file_size_bytes': bytes.length,
      };

      try {
        await _supabaseClient.from('reports').insert(reportData);
      } catch (e) {
        // Continue even if remote insertion fails, we have the local file
      }

      return Report(
        id: reportId,
        analysisId: analysisId,
        userId: userId,
        title: reportData['title'] as String,
        generatedAt: DateTime.parse(reportData['generated_at'] as String),
        format: ReportFormat.pdf,
        filePath: file.path,
        fileSizeBytes: bytes.length,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<Report>> getReportsByUser(String userId) async {
    try {
      final response = await _supabaseClient
          .from('reports')
          .select()
          .eq('user_id', userId)
          .order('generated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map(_mapToDomain)
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Report?> getReportById(String id) async {
    try {
      final response = await _supabaseClient
          .from('reports')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _mapToDomain(response);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      final report = await getReportById(id);
      if (report?.filePath != null) {
        final file = File(report!.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _supabaseClient.from('reports').delete().eq('id', id);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<String> exportReport(String reportId) async {
    try {
      final report = await getReportById(reportId);
      if (report == null || report.filePath == null) {
        throw Exception('Report file not found.');
      }
      
      final file = File(report.filePath!);
      if (!await file.exists()) {
        throw Exception('Local file no longer exists.');
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Sharing Threat Analysis Report: ${report.title}',
      );

      return file.path;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Report _mapToDomain(Map<String, dynamic> data) {
    return Report(
      id: data['id'] as String,
      analysisId: data['analysis_id'] as String,
      userId: data['user_id'] as String,
      title: data['title'] as String? ?? 'Untitled Report',
      generatedAt: DateTime.parse(data['generated_at'] as String),
      format: ReportFormat.values.firstWhere(
        (e) => e.name == data['format'],
        orElse: () => ReportFormat.pdf,
      ),
      filePath: data['file_path'] as String?,
      fileSizeBytes: data['file_size_bytes'] as int?,
    );
  }

  AppException _mapError(Object error) {
    if (error is AppException) return error;
    return NetworkException(
      message: 'Report operation failed: $error',
      originalError: error,
    );
  }

  // --- PDF Building Helpers ---

  pw.Widget _buildHeader(ThreatAnalysis analysis) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('ThreatLens AI Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Analysis ID: ${analysis.id}'),
        pw.Text('Date Generated: ${DateTime.now().toIso8601String().split('T').first}'),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildExecutiveSummary(ThreatAnalysis analysis) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Executive Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Overall Risk Score: ${analysis.riskScore?.toStringAsFixed(2) ?? "N/A"}/10'),
        pw.Text('Status: ${analysis.status.name.toUpperCase()}'),
        pw.SizedBox(height: 8),
        pw.Text('System Description:'),
        pw.Text(analysis.systemDescription),
      ],
    );
  }

  pw.Widget _buildAssetsSection(ThreatAnalysis analysis) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Assets Identified (${analysis.assets.length})', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...analysis.assets.map((asset) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(asset.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Type: ${asset.type.name} | Sensitivity: ${asset.sensitivity.name}'),
                  pw.Text('Description: ${asset.description}'),
                ],
              ),
            )),
      ],
    );
  }

  pw.Widget _buildThreatsSection(ThreatAnalysis analysis) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Threats & Mitigations (${analysis.threats.length})', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...analysis.threats.map((threat) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(threat.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.SizedBox(height: 4),
                  pw.Text('STRIDE Category: ${threat.strideCategory.name.toUpperCase()}'),
                  pw.Text('DREAD Score: ${threat.dreadScore.average.toStringAsFixed(2)}/10'),
                  pw.SizedBox(height: 4),
                  pw.Text('Description: ${threat.description}'),
                  pw.SizedBox(height: 8),
                  pw.Text('Mitigations:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (threat.mitigations.isEmpty) pw.Text('None specified.'),
                  ...threat.mitigations.map((m) => pw.Bullet(text: '[${m.priority.name.toUpperCase()}] ${m.description}')),
                ],
              ),
            )),
      ],
    );
  }
}
