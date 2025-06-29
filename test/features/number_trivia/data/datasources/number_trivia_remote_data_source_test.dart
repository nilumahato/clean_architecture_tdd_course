import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exception.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

final tNumberTriviaModel = NumberTriviaModel.fromJson(
  json.decode(fixture('trivia.json')),
);

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;

    test(
      'should perform a GET request on a URL with number being the endpoint and with application/json header',
      () async {
        // arrange
        when(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
        // act
        await dataSource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        when(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
        // act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        when(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('Something went wrong', 404));
        // act
        final call = dataSource.getConcreteNumberTrivia;
        // assert
        expect(() => call(tNumber), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia.json')),
    );

    test(
      'should perform a GET request on a URL with *random* endpoint with application/json header',
      () async {
        // arrange
        when(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
        // act
        await dataSource.getRandomNumberTrivia();
        // assert
        verify(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        when(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
        // act
        final result = await dataSource.getRandomNumberTrivia();
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        when(
          mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('Something went wrong', 404));
        // act
        final call = dataSource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );
  });
}
