// lib/blocs/text_store/text_store_bloc.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import 'text_store_event.dart';
import 'text_store_state.dart';
import '../../repositories/text_storage_repository.dart';

class TextStoreBloc extends Bloc<TextStoreEvent, TextStoreState> {
  final TextStorageRepository _repository;

  TextStoreBloc({TextStorageRepository? repository})
      : _repository = repository ?? TextStorageRepository(),
        super(TextStoreState.initial()) {
    on<InitializeController>(_onInitializeController);
    on<SaveText>(_onSaveText);
    on<LoadText>(_onLoadText);
    on<ShareText>(_onShareText);
    on<FreshStart>(_onFreshStart);
    on<LoadDocuments>(_onLoadDocuments);
  }

  void _onInitializeController(
      InitializeController event, Emitter<TextStoreState> emit) {
    emit(state.copyWith(controller: event.controller));
  }

  Future<void> _onSaveText(SaveText event, Emitter<TextStoreState> emit) async {
    if (state.controller == null) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '텍스트 컨트롤러가 초기화되지 않았습니다',
      ));
      return;
    }

    emit(state.copyWith(status: TextStoreStatus.loading));

    try {
      final document = await _repository.saveText(state.controller!.text);
      
      emit(state.copyWith(
        status: TextStoreStatus.success,
        currentDocument: document,
        // 문서 목록에도 추가
        documents: [document, ...state.documents],
      ));
      
      Fluttertoast.showToast(
        msg: "텍스트 저장 성공!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '저장 실패: ${e.toString()}',
      ));
      
      Fluttertoast.showToast(
        msg: "텍스트 저장 실패",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _onLoadText(LoadText event, Emitter<TextStoreState> emit) async {
    if (state.controller == null) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '텍스트 컨트롤러가 초기화되지 않았습니다',
      ));
      return;
    }

    emit(state.copyWith(status: TextStoreStatus.loading));

    try {
      await _repository.showTextFilesDialog(event.context, state.controller!);
      emit(state.copyWith(status: TextStoreStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '불러오기 실패: ${e.toString()}',
      ));
    }
  }

  Future<void> _onShareText(ShareText event, Emitter<TextStoreState> emit) async {
    if (state.controller == null) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '텍스트 컨트롤러가 초기화되지 않았습니다',
      ));
      return;
    }

    emit(state.copyWith(status: TextStoreStatus.loading));

    try {
      await Share.share(state.controller!.text);
      emit(state.copyWith(status: TextStoreStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '공유 실패: ${e.toString()}',
      ));
    }
  }

  void _onFreshStart(FreshStart event, Emitter<TextStoreState> emit) {
    if (state.controller == null) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '텍스트 컨트롤러가 초기화되지 않았습니다',
      ));
      return;
    }

    state.controller!.clear();
    emit(state.copyWith(
      status: TextStoreStatus.success,
      currentDocument: null, // 현재 문서 참조 제거
    ));
  }
  
  Future<void> _onLoadDocuments(LoadDocuments event, Emitter<TextStoreState> emit) async {
    emit(state.copyWith(status: TextStoreStatus.loading));
    
    try {
      final documents = await _repository.getTextDocuments();
      emit(state.copyWith(
        status: TextStoreStatus.success,
        documents: documents,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TextStoreStatus.failure,
        errorMessage: '문서 목록 불러오기 실패: ${e.toString()}',
      ));
    }
  }
}