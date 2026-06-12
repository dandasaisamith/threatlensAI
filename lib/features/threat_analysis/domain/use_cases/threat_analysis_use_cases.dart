import '../entities/threat_analysis.dart';
import '../repositories/threat_analysis_repository.dart';

/// Use case for creating a new threat analysis.
class CreateAnalysisUseCase {
  CreateAnalysisUseCase({required ThreatAnalysisRepository repository})
      : _repository = repository;

  final ThreatAnalysisRepository _repository;

  Future<ThreatAnalysis> call({
    required String userId,
    required String systemDescription,
  }) => _repository.createAnalysis(
    userId: userId,
    systemDescription: systemDescription,
  );
}

/// Use case for getting an analysis by ID.
class GetAnalysisByIdUseCase {
  GetAnalysisByIdUseCase({required ThreatAnalysisRepository repository})
      : _repository = repository;

  final ThreatAnalysisRepository _repository;

  Future<ThreatAnalysis?> call(String id) => _repository.getAnalysisById(id);
}

/// Use case for getting all analyses for a user.
class GetAnalysesByUserUseCase {
  GetAnalysesByUserUseCase({required ThreatAnalysisRepository repository})
      : _repository = repository;

  final ThreatAnalysisRepository _repository;

  Future<List<ThreatAnalysis>> call(String userId) =>
      _repository.getAnalysesByUser(userId);
}

/// Use case for deleting an analysis.
class DeleteAnalysisUseCase {
  DeleteAnalysisUseCase({required ThreatAnalysisRepository repository})
      : _repository = repository;

  final ThreatAnalysisRepository _repository;

  Future<void> call(String id) => _repository.deleteAnalysis(id);
}
