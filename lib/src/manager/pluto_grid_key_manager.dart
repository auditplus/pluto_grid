import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// 2021-11-19
/// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
/// 이슈 해결 후 : 삭제
///
/// desktop 에서만 발생
/// skipRemainingHandlers 을 리턴하면 pluto_grid.dart 의 FocusScope 의
/// 콜백이 호출 되지 않고 TextField 에 키 입력이 되어야 하는데
/// 방향키, 백스페이스 등이 입력되지 않음.(문자등은 입력 됨)
/// https://github.com/flutter/flutter/issues/93873
class PlutoGridKeyEventResult {
  bool _skip = false;

  bool get isSkip => _skip;

  KeyEventResult skip(KeyEventResult result) {
    _skip = true;

    return result;
  }

  KeyEventResult consume(KeyEventResult result) {
    if (_skip) {
      _skip = false;

      return KeyEventResult.ignored;
    }

    return result;
  }
}

class PlutoGridKeyManager {
  PlutoGridStateManager stateManager;

  PlutoGridKeyEventResult eventResult = PlutoGridKeyEventResult();

  PlutoGridKeyManager({
    required this.stateManager,
  });

  KeyEventResult handle(PlutoKeyManagerEvent keyEvent) {
    if (keyEvent.isKeyUpEvent) return KeyEventResult.ignored;

    if (stateManager.configuration.shortcut.handle(
      keyEvent: keyEvent,
      stateManager: stateManager,
      state: HardwareKeyboard.instance,
    )) {
      return KeyEventResult.handled;
    }

    return _handleDefaultActions(keyEvent);
  }

  KeyEventResult _handleDefaultActions(PlutoKeyManagerEvent keyEvent) {
    if (!keyEvent.isModifierPressed && keyEvent.isCharacter) {
      _handleCharacter(keyEvent);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleCharacter(PlutoKeyManagerEvent keyEvent) {
    if (stateManager.isEditing != true && stateManager.currentCell != null) {
      stateManager.setEditing(true);

      if (keyEvent.event.character == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (stateManager.textEditingController != null) {
          stateManager.textEditingController!.text = keyEvent.event.character!;
        }
      });
    }
  }
}
