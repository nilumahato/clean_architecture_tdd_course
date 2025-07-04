import 'package:clean_architecture_tdd_course/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/core/error/failures.dart';

import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be Empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    final tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() => when(
      mockInputConverter.stringToUnsignedInteger(tNumberString),
    ).thenReturn(Right(tNumberParsed));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
          mockInputConverter.stringToUnsignedInteger(tNumberString),
        );
        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test('should emit [Error] when the input is invalid', () async {
      // arrange
      when(
        mockInputConverter.stringToUnsignedInteger(tNumberString),
      ).thenReturn(Left(InvalidInputFailure()));
      // assert later
      final expected = [Empty(), Error(message: invalidInputFailureMessage)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      // arrange
      when(
        mockInputConverter.stringToUnsignedInteger(tNumberString),
      ).thenReturn(Right(tNumberParsed));
      when(
        mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
      ).thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(
        mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
      );
      // assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
        ).thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(
        mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
      ).thenAnswer((_) async => Left(ServerFailure()));
      // assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
        ).thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test('should get data from the random use case', () async {
      // arrange
      when(
        mockGetRandomNumberTrivia(NoParams()),
      ).thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(const GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(NoParams()));
      // assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(NoParams()),
        ).thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForRandomNumber());
      },
    );

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      when(
        mockGetRandomNumberTrivia(NoParams()),
      ).thenAnswer((_) async => Left(ServerFailure()));
      // assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(const GetTriviaForRandomNumber());
    });

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(NoParams()),
        ).thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForRandomNumber());
      },
    );
  });
}
