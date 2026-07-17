import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/service/favorites_storage.dart';

class ExerciseListTile extends StatefulWidget {
  final Exercise exercise;
  final bool selected;
  final VoidCallback? onTap;

  const ExerciseListTile({
    super.key,
    required this.exercise,
    this.selected = false,
    this.onTap,
  });

  @override
  State<ExerciseListTile> createState() => _ExerciseListTileState();
}

class _ExerciseListTileState extends State<ExerciseListTile> {
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> loadFavorite() async {
    final isFavorite = await FavoritesStorage.contains(widget.exercise.id);

    if (!mounted) return;

    setState(() {
      favorite = isFavorite;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        height: 86,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.selected
                ? AppColors.primary
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Image.asset(
                  widget.exercise.gif,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                widget.exercise.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 18,
              onPressed: () async {
                setState(() {
                  favorite = !favorite;
                });

                if(favorite) {
                  await FavoritesStorage.add(widget.exercise.id);
                } else {
                  await FavoritesStorage.remove(widget.exercise.id);
                }
              },
              icon: Icon(
                favorite ? Icons.star : Icons.star_border,
                color: favorite ? Colors.amberAccent : Colors.grey,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}