import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/exercise.dart';
import 'package:rg_gym/service/favorites_storage.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final bool selected;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.selected = false,
    this.onTap,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
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
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: widget.selected ?
            Border.all(color: AppColors.primary, width: 3)
            : null
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.exercise.gif,
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  child: IconButton(
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
                ),
              ],
            ),

            SizedBox(height: 10),

            Expanded(
              child: Center(
                child: Text(
                  widget.exercise.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}