import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'audio_event.dart';
import 'audio_state.dart';
import '../../repositories/audio_repository.dart';
import '../../constants/waveform_const.dart';
import '../../models/audio_sample.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository _repository;
  StreamSubscription? _audioSampleSubscription;
  StreamSubscription? _recognizedTextSubscription;
  StreamSubscription? _audioBufferSubscription;
  Timer? _fadeTimer;

  AudioBloc({AudioRepository? repository})
      : _repository = repository ?? AudioRepository(),
        super(AudioState.initial()) {
    on<StartRecording>((event, emit) => _onStartRecording(event, emit));
    on<StopRecording>((event, emit) => _onStopRecording(event, emit));
    on<AudioSampleReceived>(
        (event, emit) => _onAudioSampleReceived(event, emit));
    on<RecognizedTextReceived>(
        (event, emit) => _onRecognizedTextReceived(event, emit));
    on<AudioBufferReceived>(
        (event, emit) => _onAudioBufferReceived(event, emit));
    on<ClearRecognizedText>(
        (event, emit) => _onClearRecognizedText(event, emit));

    // 침묵 감지 콜백
    if (_repository is AudioRepository) {
      (_repository as AudioRepository).onSilenceDetected = () {
        // Bloc 내부에서 이벤트 추가
        add(StopRecording(silenceDetected: true));

        // 토스트 메시지는 StopRecording 이벤트 핸들러에서 처리
      };
    }

    // 리포지토리의 스트림들을 구독
    _subscribeToRepositoryStreams();
  }

  void _subscribeToRepositoryStreams() {
    // 오디오 샘플 스트림 구독
    _audioSampleSubscription = _repository.amplitudeStream.listen((sample) {
      add(AudioSampleReceived(sample));
    });

    // 인식된 텍스트 스트림 구독
    _recognizedTextSubscription = _repository.textStream.listen((text) {
      add(RecognizedTextReceived(text));
    });

    // 오디오 버퍼 스트림 구독
    _audioBufferSubscription = _repository.bufferStream.listen((buffer) {
      add(AudioBufferReceived(buffer));
    });
  }

  Future<void> _onStartRecording(
      StartRecording event, Emitter<AudioState> emit) async {
    // 마이크 권한 확인
    if (!(await Permission.microphone.isGranted)) {
      PermissionStatus status = await Permission.microphone.request();
      if (!status.isGranted) {
        emit(state.copyWith(
          status: AudioStatus.error,
          errorMessage: '마이크 권한이 필요합니다',
        ));
        return;
      }
    }

    try {
      // 이전 텍스트 초기화
      emit(state.copyWith(
        recognizedTexts: [],
        clearError: true,
      ));

      await _repository.startRecording();

      emit(state.copyWith(
        status: AudioStatus.recording,
        isRecording: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: '녹음 시작 실패: ${e.toString()}',
        isRecording: false,
      ));
    }
  }

  Future<void> _onStopRecording(
      StopRecording event, Emitter<AudioState> emit) async {
    print("⚠️ StopRecording 이벤트 처리 시작: 현재 녹음 상태 = ${state.isRecording}");

    // 상태가 이미 녹음 중지되어 있는지 확인하고, 중복 처리 방지
    if (!state.isRecording) {
      print("⚠️ 이미 녹음이 중지된 상태입니다. 중복 처리 스킵.");
      return;
    }

    // 즉시 상태 업데이트 (UI 반응성 향상)
    emit(state.copyWith(
      status: AudioStatus.idle,
      isRecording: false,
    ));

    print("⚠️ AudioState 업데이트 완료: isRecording = false");

    // 실제 녹음 중지 로직 실행
    await _repository.stopRecording();

    print("⚠️ Repository의 stopRecording 완료");

    // 녹음 중지 후 진폭을 서서히 감소시키는 로직 - emit 인자 제거
    _startFadeOutAmplitude();

    // 침묵 감지에 의한 녹음 중지인 경우 토스트 메시지 표시
    if (event.silenceDetected) {
      // 비동기 작업이므로 Bloc 외부에서 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: "침묵이 감지되어 녹음이 중지되었습니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[700],
          textColor: Colors.white,
        );
      });
    }

    print("⚠️ StopRecording 이벤트 처리 완료");
  }

  void _onAudioSampleReceived(
      AudioSampleReceived event, Emitter<AudioState> emit) {
    emit(state.copyWith(lastSample: event.sample));

    // 침묵 감지 로직은 리포지토리에서 처리
    _repository.checkSilence();
  }

  void _onRecognizedTextReceived(
      RecognizedTextReceived event, Emitter<AudioState> emit) {
    // 빈 텍스트는 무시
    if (event.recognizedText.text.isEmpty) return;

    // 최종 텍스트가 아니면 목록에 추가
    if (!event.recognizedText.isFinal) {
      emit(state.copyWith(
        recognizedTexts: [...state.recognizedTexts, event.recognizedText],
      ));
    }
  }

  void _onAudioBufferReceived(
      AudioBufferReceived event, Emitter<AudioState> emit) {
    emit(state.copyWith(lastBuffer: event.buffer));
  }

  void _onClearRecognizedText(
      ClearRecognizedText event, Emitter<AudioState> emit) {
    emit(state.copyWith(recognizedTexts: []));
  }

// 수정된 코드 - 타이머 내부에서 직접 emit 하지 않고 새 이벤트 추가
  void _startFadeOutAmplitude() {
    if (state.lastSample == null) return;

    _fadeTimer?.cancel();

    double currentAmplitude = state.lastSample!.amplitude;
    DateTime now = DateTime.now();

    _fadeTimer = Timer.periodic(
      Duration(milliseconds: WaveformConst.MILLISEC_PER_STEP),
      (timer) {
        currentAmplitude = currentAmplitude * WaveformConst.FADING_SLOPE -
            WaveformConst.FADING_CONST;

        if (currentAmplitude <= 0) {
          currentAmplitude = 0;
          timer.cancel();
        }

        // emit 대신 새 이벤트 추가
        add(AudioSampleReceived(AudioSample(
          amplitude: currentAmplitude,
          timestamp: now,
          isSpeaking: false,
        )));
      },
    );
  }

  @override
  Future<void> close() {
    _audioSampleSubscription?.cancel();
    _recognizedTextSubscription?.cancel();
    _audioBufferSubscription?.cancel();
    _fadeTimer?.cancel();
    _repository.dispose();
    return super.close();
  }
}
