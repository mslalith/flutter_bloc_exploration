import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_exploration/core/flight/flight.dart';
import 'package:flutter_bloc_exploration/core/service/numbers_api_service.dart';

class FlightPageUiState {
  final String? numberTrivia;
  final bool isApiFetch1InProgress;
  final bool isApiFetch2InProgress;
  final int invokationCount;

  const FlightPageUiState({
    this.numberTrivia,
    this.isApiFetch1InProgress = false,
    this.isApiFetch2InProgress = false,
    this.invokationCount = 0,
  });

  FlightPageUiState copyWith({
    bool? isApiFetch2InProgress,
    bool? isApiFetch1InProgress,
    String? numberTrivia,
    int? invokationCount,
  }) {
    return FlightPageUiState(
      isApiFetch2InProgress: isApiFetch2InProgress ?? this.isApiFetch2InProgress,
      isApiFetch1InProgress: isApiFetch1InProgress ?? this.isApiFetch1InProgress,
      numberTrivia: numberTrivia ?? this.numberTrivia,
      invokationCount: invokationCount ?? this.invokationCount,
    );
  }
}

class FlightCubit extends Cubit<FlightPageUiState> {

  FlightCubit() : super(FlightPageUiState());

  final _fetchNumberTriviaFlight = Flight<String?>(
    fetcher: () async {
      await Future.delayed(const Duration(seconds: 2));
      return NumbersApiService.instance.fetchRandomNumberTrivia();
    }
  );

  Future<void> fetchFrom1() async {
    emit(state.copyWith(isApiFetch1InProgress: true));
    await _fetchNumberTriviaFlight.fetch(force: true);

    await Future.delayed(Duration(milliseconds: Random().nextInt(50)));
    emit(
      state.copyWith(
        isApiFetch1InProgress: false,
        numberTrivia: await _fetchNumberTriviaFlight.get(),
        invokationCount: _fetchNumberTriviaFlight.invokationCount,
      )
    );
  }

  Future<void> fetchFrom2() async {
    emit(state.copyWith(isApiFetch2InProgress: true));
    await _fetchNumberTriviaFlight.fetch(force: true);

    await Future.delayed(Duration(milliseconds: Random().nextInt(100) + 50));
    emit(
      state.copyWith(
        isApiFetch2InProgress: false,
        numberTrivia: await _fetchNumberTriviaFlight.get(),
        invokationCount: _fetchNumberTriviaFlight.invokationCount,
      )
    );
  }
}
