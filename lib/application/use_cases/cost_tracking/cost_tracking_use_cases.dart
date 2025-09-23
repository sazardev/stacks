// Cost Tracking Use Cases for Clean Architecture Application Layer
// Complete coverage for Cost, CostCenter, ProfitabilityReport, and RecipeCost entities

import 'package:dartz/dartz.dart' show Either, Unit, Left;
import 'package:injectable/injectable.dart';
import '../../../domain/entities/cost_tracking.dart';
import '../../../domain/repositories/cost_tracking_repository.dart';
import '../../../domain/failures/failures.dart';
import '../../../domain/value_objects/user_id.dart';
import '../../../domain/value_objects/time.dart';
import '../../../domain/value_objects/money.dart';
import '../../dtos/cost_tracking_dtos.dart';

/// Use case for creating a cost entry
@injectable
class CreateCostUseCase {
  final CostTrackingRepository _repository;

  const CreateCostUseCase(this._repository);

  Future<Either<Failure, Cost>> call(CreateCostDto dto) {
    return _repository.createCost(dto.toEntity());
  }
}

/// Use case for updating a cost entry
class UpdateCostUseCase {
  final CostTrackingRepository _repository;

  const UpdateCostUseCase(this._repository);

  Future<Either<Failure, Cost>> call(UpdateCostDto dto) async {
    final currentCostResult = await _repository.getCostById(dto.id);

    return currentCostResult.fold((failure) => Left(failure), (currentCost) {
      final updatedCost = Cost(
        id: currentCost.id,
        description: dto.description ?? currentCost.description,
        type: dto.type ?? currentCost.type,
        category: dto.category ?? currentCost.category,
        amount: dto.amount ?? currentCost.amount,
        incurredDate: dto.incurredDate ?? currentCost.incurredDate,
        relatedItemId: dto.relatedItemId ?? currentCost.relatedItemId,
        costCenterId: dto.costCenterId ?? currentCost.costCenterId,
        allocationMethod: dto.allocationMethod ?? currentCost.allocationMethod,
        quantity: dto.quantity ?? currentCost.quantity,
        unit: dto.unit ?? currentCost.unit,
        unitCost: dto.unitCost ?? currentCost.unitCost,
        recordedBy: currentCost.recordedBy,
        recordedAt: currentCost.recordedAt,
        isRecurring: dto.isRecurring ?? currentCost.isRecurring,
        recurringInterval:
            dto.recurringInterval ?? currentCost.recurringInterval,
        notes: dto.notes ?? currentCost.notes,
        metadata: dto.metadata ?? currentCost.metadata,
      );

      return _repository.updateCost(updatedCost);
    });
  }
}

/// Use case for getting a cost by ID
class GetCostByIdUseCase {
  final CostTrackingRepository _repository;

  const GetCostByIdUseCase(this._repository);

  Future<Either<Failure, Cost>> call(UserId costId) {
    return _repository.getCostById(costId);
  }
}

/// Use case for deleting a cost entry
class DeleteCostUseCase {
  final CostTrackingRepository _repository;

  const DeleteCostUseCase(this._repository);

  Future<Either<Failure, Unit>> call(UserId costId) {
    return _repository.deleteCost(costId);
  }
}

/// Use case for getting costs by type
class GetCostsByTypeUseCase {
  final CostTrackingRepository _repository;

  const GetCostsByTypeUseCase(this._repository);

  Future<Either<Failure, List<Cost>>> call(CostType type) {
    return _repository.getCostsByType(type);
  }
}

/// Use case for getting costs by category
class GetCostsByCategoryUseCase {
  final CostTrackingRepository _repository;

  const GetCostsByCategoryUseCase(this._repository);

  Future<Either<Failure, List<Cost>>> call(CostCategory category) {
    return _repository.getCostsByCategory(category);
  }
}

/// Use case for getting costs by date range
class GetCostsByDateRangeUseCase {
  final CostTrackingRepository _repository;

  const GetCostsByDateRangeUseCase(this._repository);

  Future<Either<Failure, List<Cost>>> call(CostQueryDto query) {
    if (query.startDate == null || query.endDate == null) {
      return Future.value(
        Left(ValidationFailure('Start date and end date are required')),
      );
    }
    return _repository.getCostsByDateRange(query.startDate!, query.endDate!);
  }
}

/// Use case for getting costs by cost center
class GetCostsByCostCenterUseCase {
  final CostTrackingRepository _repository;

  const GetCostsByCostCenterUseCase(this._repository);

  Future<Either<Failure, List<Cost>>> call(UserId costCenterId) {
    return _repository.getCostsByCostCenter(costCenterId);
  }
}

/// Use case for getting recurring costs
class GetRecurringCostsUseCase {
  final CostTrackingRepository _repository;

  const GetRecurringCostsUseCase(this._repository);

  Future<Either<Failure, List<Cost>>> call() {
    return _repository.getRecurringCosts();
  }
}

/// Use case for searching costs by description
class SearchCostsByDescriptionUseCase {
  final CostTrackingRepository _repository;

  const SearchCostsByDescriptionUseCase(this._repository);

  Future<Either<Failure, List<Cost>>> call(String query) {
    return _repository.searchCostsByDescription(query);
  }
}

/// Use case for creating a cost center
@injectable
class CreateCostCenterUseCase {
  final CostTrackingRepository _repository;

  const CreateCostCenterUseCase(this._repository);

  Future<Either<Failure, CostCenter>> call(CreateCostCenterDto dto) {
    return _repository.createCostCenter(dto.toEntity());
  }
}

/// Use case for getting a cost center by ID
class GetCostCenterByIdUseCase {
  final CostTrackingRepository _repository;

  const GetCostCenterByIdUseCase(this._repository);

  Future<Either<Failure, CostCenter>> call(UserId costCenterId) {
    return _repository.getCostCenterById(costCenterId);
  }
}

/// Use case for getting all cost centers
class GetAllCostCentersUseCase {
  final CostTrackingRepository _repository;

  const GetAllCostCentersUseCase(this._repository);

  Future<Either<Failure, List<CostCenter>>> call() {
    return _repository.getAllCostCenters();
  }
}

/// Use case for getting active cost centers
class GetActiveCostCentersUseCase {
  final CostTrackingRepository _repository;

  const GetActiveCostCentersUseCase(this._repository);

  Future<Either<Failure, List<CostCenter>>> call() {
    return _repository.getActiveCostCenters();
  }
}

/// Use case for getting cost centers over budget
class GetCostCentersOverBudgetUseCase {
  final CostTrackingRepository _repository;

  const GetCostCentersOverBudgetUseCase(this._repository);

  Future<Either<Failure, List<CostCenter>>> call() {
    return _repository.getCostCentersOverBudget();
  }
}

/// Use case for generating a profitability report
class GenerateProfitabilityReportUseCase {
  final CostTrackingRepository _repository;

  const GenerateProfitabilityReportUseCase(this._repository);

  Future<Either<Failure, ProfitabilityReport>> call(
    GenerateProfitabilityReportDto dto,
  ) {
    return _repository.createProfitabilityReport(dto.toEntity());
  }
}

/// Use case for getting profitability reports by date range
class GetProfitabilityReportsByDateRangeUseCase {
  final CostTrackingRepository _repository;

  const GetProfitabilityReportsByDateRangeUseCase(this._repository);

  Future<Either<Failure, List<ProfitabilityReport>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getProfitabilityReportsByDateRange(startDate, endDate);
  }
}

/// Use case for creating recipe cost analysis
class CreateRecipeCostUseCase {
  final CostTrackingRepository _repository;

  const CreateRecipeCostUseCase(this._repository);

  Future<Either<Failure, RecipeCost>> call(CreateRecipeCostDto dto) {
    return _repository.createRecipeCost(dto.toEntity());
  }
}

/// Use case for getting recipe costs by recipe ID
class GetRecipeCostsByRecipeIdUseCase {
  final CostTrackingRepository _repository;

  const GetRecipeCostsByRecipeIdUseCase(this._repository);

  Future<Either<Failure, List<RecipeCost>>> call(UserId recipeId) {
    return _repository.getRecipeCostsByRecipeId(recipeId);
  }
}

/// Use case for getting current recipe pricing
class GetCurrentRecipePricingUseCase {
  final CostTrackingRepository _repository;

  const GetCurrentRecipePricingUseCase(this._repository);

  Future<Either<Failure, List<RecipeCost>>> call() {
    return _repository.getCurrentRecipePricing();
  }
}

/// Use case for getting total costs for a period
class GetTotalCostsForPeriodUseCase {
  final CostTrackingRepository _repository;

  const GetTotalCostsForPeriodUseCase(this._repository);

  Future<Either<Failure, Money>> call(Time startDate, Time endDate) {
    return _repository.getTotalCostsForPeriod(startDate, endDate);
  }
}

/// Use case for getting cost breakdown by type
class GetCostBreakdownByTypeUseCase {
  final CostTrackingRepository _repository;

  const GetCostBreakdownByTypeUseCase(this._repository);

  Future<Either<Failure, Map<CostType, Money>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getCostBreakdownByType(startDate, endDate);
  }
}

/// Use case for getting cost breakdown by category
class GetCostBreakdownByCategoryUseCase {
  final CostTrackingRepository _repository;

  const GetCostBreakdownByCategoryUseCase(this._repository);

  Future<Either<Failure, Map<CostCategory, Money>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getCostBreakdownByCategory(startDate, endDate);
  }
}

/// Use case for getting top expensive items
class GetTopExpensiveItemsUseCase {
  final CostTrackingRepository _repository;

  const GetTopExpensiveItemsUseCase(this._repository);

  Future<Either<Failure, List<Cost>>> call(int limit) {
    return _repository.getTopExpensiveItems(limit);
  }
}

/// Use case for getting cost trends
class GetCostTrendsUseCase {
  final CostTrackingRepository _repository;

  const GetCostTrendsUseCase(this._repository);

  Future<Either<Failure, Map<Time, Money>>> call(
    Time startDate,
    Time endDate,
    Duration interval,
  ) {
    return _repository.getCostTrends(startDate, endDate, interval);
  }
}

/// Use case for calculating budget variance
class CalculateBudgetVarianceUseCase {
  final CostTrackingRepository _repository;

  const CalculateBudgetVarianceUseCase(this._repository);

  Future<Either<Failure, Map<UserId, double>>> call(
    UserId costCenterId,
    Time periodStart,
    Time periodEnd,
  ) {
    return _repository.calculateBudgetVariance(
      costCenterId,
      periodStart,
      periodEnd,
    );
  }
}

/// Use case for getting cost efficiency metrics
class GetCostEfficiencyMetricsUseCase {
  final CostTrackingRepository _repository;

  const GetCostEfficiencyMetricsUseCase(this._repository);

  Future<Either<Failure, Map<String, double>>> call(
    Time startDate,
    Time endDate,
  ) {
    return _repository.getCostEfficiencyMetrics(startDate, endDate);
  }
}
