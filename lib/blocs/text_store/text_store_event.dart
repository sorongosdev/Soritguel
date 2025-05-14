// lib/blocs/text_store/text_store_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class TextStoreEvent extends Equatable {
  const TextStoreEvent();

  @override
  List<Object> get props => [];
}

class InitializeController extends TextStoreEvent {
  final TextEditingController controller;

  const InitializeController(this.controller);

  @override
  List<Object> get props => [controller];
}

class SaveText extends TextStoreEvent {}

class LoadText extends TextStoreEvent {
  final BuildContext context;

  const LoadText(this.context);

  @override
  List<Object> get props => [context];
}

class ShareText extends TextStoreEvent {}

class FreshStart extends TextStoreEvent {}

// 추가: 문서 목록 로드 이벤트
class LoadDocuments extends TextStoreEvent {}