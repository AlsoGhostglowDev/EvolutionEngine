# Contributing Rules
These rules should be easy to follow. Please do not the engine for your personal gain. 

## Adding Changes to Source Code
### Adding a File:
If you want to add a file, please do not add anything to `import.hx` for imports unless you are adding a lot of files that actually utilize that module/class

### Changes to files:
Changing the contents of the file shouldn't be a problem if it doesn't cause any major problems<br>
> [!NOTE]
> ### Outdated Classes:
> If you're using a class that is moved to another package or anything that can cause problems to the commonly used older versions, please do this fix. <br>
> e.g: `FlxSound` was moved from `flixel.system` to `flixel.sound` on version 5.3.0. This can be fixed with a preprocessor check like so:
> ```hx
> #if (flixel < 5.3.0)
> import flixel.system.FlxSound;
> #else
> import flixel.sound.FlxSound;
> #end
> ```

> [!IMPORTANT]
> ### Prioritize Optimization:
> Prioritize optimization for the engine while still keeping the code manageable and readable.
> ### Major Changes:
> When making a major change to the source code, contact me regarding the change first. Describe what your goal was and how it can make the engine better.
>
> ### Linking the code to a external machine:
> If you are to link a variable to a external website, your pull request will be likely rejected because a lot of things can happen; i.e. if the variable to link contains the user's personal and sensitive information. 

### Fixing a bug:
When fixing a bug, make sure the fix doesn't cause *another* bug.
