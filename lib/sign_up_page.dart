import 'dart:math';

import 'package:flutter/material.dart';
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

    // ⑥ キーボードの高さを `viewInsets` から取得
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final textEditingController = useTextEditingController();
    final focusNode = useFocusNode();
    final scrollController = useScrollController();
    final isFocused = useState(false);
    final imageHeight = useState(0.0);

    // 画像の高さを取得する処理
    useEffect(
      () {
        // 画像の読み込み完了を待つ
        final image = Image.asset('assets/ozisan.png').image;
        final imageStream = image.resolve(ImageConfiguration.empty);

        final listener = ImageStreamListener(
          (ImageInfo info, bool _) {
            // ③ 画像の高さを取得する
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final renderBox =
                  imageKey.currentContext?.findRenderObject() as RenderBox?;
              imageHeight.value = renderBox?.size.height ?? 0.0;
            });
          },
          onError: (dynamic exception, StackTrace? stackTrace) {
            // エラー処理
          },
        );

        imageStream.addListener(listener);
        return () {
          imageStream.removeListener(listener);
        };
      },
      const [],
    );

    // キーボードの表示状態に応じてスクロールする処理
    useEffect(
      () {
        final observer = _KeyboardVisibilityListener(
          onKeyboardVisibilityChanged: () {
            // ⑧ キーボードが表示されたら一番下までスクロールをしてテキスト入力がしやすいようにする
            //
            // これにより、キーボードが表示されている最中に最下部の表示を保持できる。
            // ※Androidで初回のみキーボードに追従しないことがあるので、
            //  レイアウトの再計算を待ってからスクロールを実行。
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final maxScrollExtent = scrollController.position.maxScrollExtent;
              scrollController.jumpTo(maxScrollExtent);
            });
          },
        );
        WidgetsBinding.instance.addObserver(observer);
        return () {
          WidgetsBinding.instance.removeObserver(observer);
        };
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
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              // ② スマホ画面の高さに応じたUIを描画する
              //
              // ⑤ スマホ画面の大きさの制約を除く（これでキーボードを表示しても画像が小さくなりません）
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
                    // ⑦ `viewInsets`の値を使用してスクロール画面の一番下にキーボード表示用のスペースを設ける
                    //
                    // セーフエリアのない端末の場合はUIの微調整をする
                    height: bottomInset + max(safeAreaPadding.bottom, 16),
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

/// キーボードの表示状態を監視するクラス
class _KeyboardVisibilityListener extends WidgetsBindingObserver {
  _KeyboardVisibilityListener({
    required this.onKeyboardVisibilityChanged,
  });
  final void Function() onKeyboardVisibilityChanged;

  @override
  void didChangeMetrics() {
    onKeyboardVisibilityChanged();
  }
}
