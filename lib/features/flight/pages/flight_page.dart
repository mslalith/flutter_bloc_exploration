import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_exploration/core/models/anime_quote.dart';
import 'package:flutter_bloc_exploration/features/flight/bloc/flight_cubit.dart';

class FlightPage extends StatelessWidget {
  const FlightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FlightCubit(),
      child: const _FlightPage(),
    );
  }
}

class _FlightPage extends StatelessWidget {
  const _FlightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _InvokationCount(),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Expanded(
                  child: _ActionProgressButton(
                    text: 'API fetch 1',
                    selector: (state) => state.isApiFetch1InProgress,
                    onClick: () => context.read<FlightCubit>().fetchFrom1(),
                  ),
                ),
                Expanded(
                  child: _ActionProgressButton(
                    text: 'API fetch 2',
                    selector: (state) => state.isApiFetch2InProgress,
                    onClick: () => context.read<FlightCubit>().fetchFrom2(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            const _NumberTrivia(),
          ],
        ),
      ),
    );
  }
}

class _ActionProgressButton extends StatelessWidget {
  final String text;
  final bool Function(FlightPageUiState) selector;
  final VoidCallback onClick;

  const _ActionProgressButton({
    super.key,
    required this.text,
    required this.selector,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: onClick,
          child: Text(text),
        ),
        BlocSelector<FlightCubit, FlightPageUiState, bool>(
          selector: selector,
          builder: (context, isInProgress) => isInProgress ? Text('In progress') : SizedBox(),
        ),
      ],
    );
  }
}

class _InvokationCount extends StatelessWidget {
  const _InvokationCount({super.key});

  @override
  Widget build(BuildContext context) {
    final invokationCount = context.select<FlightCubit, int>((cubit) => cubit.state.invokationCount);

    return Text(invokationCount.toString());
  }
}

class _NumberTrivia extends StatelessWidget {
  const _NumberTrivia({super.key});

  @override
  Widget build(BuildContext context) {
    final numberTrivia = context.select<FlightCubit, String?>((cubit) => cubit.state.numberTrivia);

    return Text(numberTrivia ?? '');
  }
}
