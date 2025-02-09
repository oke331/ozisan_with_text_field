import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OzisanPage extends HookWidget {
  const OzisanPage({super.key});

  /// 画像の高さを取得するためのキー
  static final imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeAreaPadding = MediaQuery.paddingOf(context);

    // ① デバイスの高さを取得
    final deviceHeight = MediaQuery.sizeOf(context).height;

    final textEditingController = useTextEditingController();
    final focusNode = useFocusNode();
    final scrollController = useScrollController();
    final isFocused = useState(false);
    final imageHeight = useState(0.0);

    // 画像の高さを取得する処理
    useEffect(
      () {
        // ③ 画像の高さを取得する
        //
        // 画像のレンダリング完了後、確実に高さを取得する
        SchedulerBinding.instance.addPostFrameCallback((_) {
          void measureHeight() {
            final renderBox =
                imageKey.currentContext?.findRenderObject() as RenderBox?;
            final height = renderBox?.size.height ?? 0.0;
            if (height > 0) {
              imageHeight.value = height;
            } else {
              // 高さが0の場合、次のフレームで再試行
              SchedulerBinding.instance.addPostFrameCallback((_) {
                measureHeight();
              });
            }
          }

          measureHeight();
        });
        return null;
      },
      const [],
    );

    // テキストフィールドにフォーカスが当たっている状態を管理する処理
    useEffect(
      () {
        void listener() {
          final hasFocus = focusNode.hasFocus;
          isFocused.value = hasFocus;
        }

        focusNode.addListener(listener);
        return () {
          focusNode.removeListener(listener);
        };
      },
      [focusNode],
    );

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              // ② スマホ画面の高さに応じたUIを描画する
              //
              // ⑤ スマホ画面の大きさの制約を除く（キーボードが開かれた際、下部のWidgetが切り替わり余分な余白が生まれるのを避けるためです）
              height: imageHeight.value == 0.0 ? deviceHeight : null,
              child: Column(
                children: [
                  SizedBox(height: safeAreaPadding.top),
                  const SizedBox(height: 20),
                  Text(
                    'おじさんはすごい！',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (imageHeight.value == 0.0)
                    Expanded(
                      child: Image.asset(
                        'assets/ozisan.png',
                        key: imageKey,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    // ④ 画像の高さを固定にする
                    Image.asset(
                      'assets/ozisan.png',
                      height: imageHeight.value,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 32),
                  Text(
                    '何でも知ってるおじさんです。',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    focusNode: focusNode,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: '褒め言葉を入力',
                    ),
                    // ⑥ キーボード表示で最下部までスクロールされるようにする。（下部のWidgetは可変で高さが取得できないので、大きい値を使用しています）
                    scrollPadding: EdgeInsets.only(
                      bottom: deviceHeight,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isFocused.value) ...[
                    Text('テキスト入力でおじさんを褒めてあげて！'),
                    SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('うれしい！'),
                        ),
                      );
                    },
                    child: const Text('おじさんを褒める'),
                  ),
                  if (!isFocused.value) ...[
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('おじさんが変わりました！'),
                          ),
                        );
                      },
                      child: const Text('別のおじさんを見る'),
                    ),
                  ],
                  SizedBox(
                    // セーフエリアのない端末の場合はUIの微調整をする
                    height: max(safeAreaPadding.bottom, 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
