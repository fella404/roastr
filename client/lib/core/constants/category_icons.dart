import 'package:flutter/material.dart';

class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> iconMap = {
    'fastfood': Icons.fastfood,
    'local_cafe': Icons.local_cafe,
    'cake': Icons.cake,
    'restaurant': Icons.restaurant,
    'local_pizza': Icons.local_pizza,
    'lunch_dining': Icons.lunch_dining,
    'local_bar': Icons.local_bar,
    'icecream': Icons.icecream,
    'ramen_dining': Icons.ramen_dining,
    'bakery_dining': Icons.bakery_dining,
    'breakfast_dining': Icons.breakfast_dining,
    'dinner_dining': Icons.dinner_dining,
    'emoji_food_beverage': Icons.emoji_food_beverage,
    'coffee': Icons.coffee,
    'wine_bar': Icons.wine_bar,
    'local_drink': Icons.local_drink,
    'tapas': Icons.tapas,
    'brunch_dining': Icons.brunch_dining,
    'set_meal': Icons.set_meal,
    'rice_bowl': Icons.rice_bowl,
  };

  static IconData? getIcon(String key) => iconMap[key];

  static List<String> get availableIcons => iconMap.keys.toList();
}
