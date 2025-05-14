// lib/blocs/text_store/text_store_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/text_document.dart';

enum TextStoreStatus { initial, loading, success, failure }

class TextStoreState extends Equatable {
  final TextEditingController? controller;
  final TextStoreStatus status;
  final String? errorMessage;
  final List<TextDocument> documents;
  final TextDocument? currentDocument;

  const TextStoreState({
    this.controller,
    this.status = TextStoreStatus.initial,
    this.errorMessage,
    this.documents = const [],
    this.currentDocument,
  });

  factory TextStoreState.initial() {
    return const TextStoreState();
  }

  TextStoreState copyWith({
    TextEditingController? controller,
    TextStoreStatus? status,
    String? errorMessage,
    List<TextDocument>? documents,
    TextDocument? currentDocument,
    bool clearError = false,
  }) {
    return TextStoreState(
      controller: controller ?? this.controller,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      documents: documents ?? this.documents,
      currentDocument: currentDocument ?? this.currentDocument,
    );
  }

  @override
  List<Object?> get props => [controller, status, errorMessage, documents, currentDocument];
}