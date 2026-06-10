import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// Use case for generating a report.
class GenerateReportUseCase {
  GenerateReportUseCase({required ReportRepository repository})
      : _repository = repository;

  final ReportRepository _repository;

  Future<Report> call({
    required String analysisId,
    required String userId,
    required ReportFormat format,
  }) {
    return _repository.generateReport(
      analysisId: analysisId,
      userId: userId,
      format: format,
    );
  }
}

/// Use case for getting all reports for a user.
class GetReportsByUserUseCase {
  GetReportsByUserUseCase({required ReportRepository repository})
      : _repository = repository;

  final ReportRepository _repository;

  Future<List<Report>> call(String userId) =>
      _repository.getReportsByUser(userId);
}
