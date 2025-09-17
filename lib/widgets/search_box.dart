import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/home_providers.dart';

class SearchBox extends HookConsumerWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(
      text: ref.read(searchQueryProvider), // 初期値
    );
    useListenable(controller);

    void onChanged(String text) {
      ref.read(searchQueryProvider.notifier).state = text;
    }
    final focusNode = useFocusNode();
    useEffect(() {
      void listener() {

        if (!focusNode.hasFocus) {
          // print('unfocused');
        }
      }
      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, [focusNode]);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '検索',
        prefixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            focusNode.requestFocus();
          },
            ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                    Icons.clear,
                  color: Colors.black,
                ),
                onPressed: () {
                  controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                  focusNode.unfocus();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

      ),
      onSubmitted: (_) {
        focusNode.unfocus();
      },
      style: const TextStyle(fontSize: 18),
    );
  }
}
