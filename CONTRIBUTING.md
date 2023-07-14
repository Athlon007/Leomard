# Contributing

_Last updated: 2023-07-14_

Befere contributing, please read the [Code of Conduct](CODE_OF_CONDUCT.md).

## General

If you want to contribute to this project, you can do so by forking the repository, and then creating a pull request. You can also create an issue if you find a bug or have a feature request.

Any code you write must be licensed under GPL-3.0. See [LICENSE](LICENSE.md) for more information.

## Code style

Please follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). If you find any violations, please feel free to open a pull request.

The main project folder is divided into following subfolders:

- Assets: Contains the assets used in the app.
- AppStorage: Contains the source code of whatever is saved in the app storage.
- Models: Contains the source code of the models used in the app.
- Models/Leomard: Used only by Leomard
- Models/Lemmy: Models provided by the Lemmy API.
- Services: Contains the source code of the services used in the app.
- Utils: Various utilities used in the app.
- Views: Contains the source code of the views used in the app.

Only store one struct/class per file, unless the struct/class is a substruct/subclass of another struct/class, or that struct/class is only used within the file. If that's the case, mark the struct/class as `fileprivate`.

Never create a new instance of `UserPreferences` or `SessionStorage` structs, always use the shared instance.

Please pass services from `ContentView` into the other views (aka: dependency injection), instead of creating new instances of the services in the other views.

Remember to use `LazyVStack` instead of `VStack` when loading a lot of elements.

Always prefer `struct` over `class`, unless you need inheritance or reference semantics.

Always prefer `let` over `var`, unless you need to mutate the variable.

I sometimes may not follow my own guidelines (sorry!). If you find any violations, please feel free to open a pull request.

## What to work on

You can work on whatever you want from [Projects/Leomard](https://github.com/users/Athlon007/projects/3/views/1). If something is in the "In progress" column, please do not work on it, unless you have been assigned to it. First table is for the current version, those features are the most important. Please avoid working on features that are in the "Future" column or the next update column, unless you have been assigned to it. You can also work on stuff from the "Bugs" column.

If you want to work on something that is not in the project, please create an issue first. Your idea will be discussed, and if it is accepted, it will be added to the project.

## Translations

As for now, only English is supported and no translations are planned, until the app is more stable. This is because the app is still in early development, and the translations would have to be updated every time a new feature is added. An announcement will be made when the work on translations starts.

## Conclusion

Thank you for reading this, and thank you for contributing to this project! If you have any questions, feel free to open an issue, or contact me via email: [mail@kfigura.nl](mail@kfigura.nl)