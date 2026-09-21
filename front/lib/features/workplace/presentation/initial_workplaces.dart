import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/workplace_model.dart';

part 'initial_workplaces.g.dart';

// 로그인/회원가입 응답에 실려온 내 근무지 목록을 MyWorkplaces가 처음 빌드될 때 한 번만 쓰도록
// 넘겨주는 통로 — 그대로 두면 로그인 직후 `/workplaces/my`를 왕복 한 번 더 호출한다.
// provider의 state가 아니라 일반 객체의 필드로 들고 있는 이유: 다른 provider의 build 도중에는
// state를 바꿀 수 없어서, 값을 꺼내면서 비우는(take) 동작을 build 안에서 할 수 없기 때문이다.
// MyWorkplaces(와 그 저장소/API)를 끌어오지 않도록 별도 파일로 뒀다 — auth 쪽은 첫 번들에 들어간다.
class InitialWorkplaces {
  List<WorkplaceModel>? _value;

  // null로 덮어쓰는 것도 의도된 동작이다: 서버가 목록을 안 내려줬을 때 이전 사용자의 값이
  // 남아서 다음 사용자에게 보이지 않게 한다.
  void seed(List<WorkplaceModel>? workplaces) => _value = workplaces;

  List<WorkplaceModel>? take() {
    final value = _value;
    _value = null;
    return value;
  }
}

@Riverpod(keepAlive: true)
InitialWorkplaces initialWorkplaces(Ref ref) => InitialWorkplaces();
