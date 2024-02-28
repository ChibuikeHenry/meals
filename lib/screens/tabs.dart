import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/filters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/widgets/main_drawer.dart';

import '../models/meal.dart';
import '../models/providers/favourite_provider.dart';
import '../models/providers/meals_provider.dart';

const kInitialFilters = {
Filter.glutenFree: false,
Filter.vegetarian: false,
Filter.vegan: false,
Filter.lactoseFree: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  Map<Filter, bool> _selectedFilters = kInitialFilters;

  // void _showInfoMessage(String message) {
    // ScaffoldMessenger.of(context).clearSnackBars();
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(message),
    //   ),
    // );
  // }


  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(builder:
            (context) =>  FiltersScreen(currentFilters: _selectedFilters,
            )
        ),
      );
      setState(() {
        _selectedFilters = result ?? kInitialFilters;
      });


    }
  }

  @override
  Widget build(BuildContext context) {
  final meals =  ref.watch(mealsProvider);
   final availableMeals = meals.where((meal)  {
     if (_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree){
       return false;
     }          if (_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree){
       return false;
     }          if (_selectedFilters[Filter.vegan]! && !meal.isVegan){
       return false;
     }     if (_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian){
       return false;
     }
     return true;
   }).toList();

    Widget activePage = CategoriesScreen(
      availableMeals: availableMeals,
    );
    var activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      final favoriteMeals = ref.watch(favoriteMealsProvider);
      activePage = MealsScreen(
        meals: favoriteMeals,
      );
      activePageTitle = 'Your Favorites';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: "Category",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favourite'),
        ],
      ),
    );
  }
}