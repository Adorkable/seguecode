# seguecode

[![Travis Build Status](http://img.shields.io/travis/Adorkable/seguecode.svg?style=flat)](https://travis-ci.org/Adorkable/seguecode)

**seguecode** is a support tool to use alongside `UIStoryboard` development. It provides compile-time safeties around building with `UIStoryboard`s in an effort to create an error free workflow so you can focus on the important things.

This include exposing:

* Storyboard Scene Identifiers
* Segue Identifiers
* Table View Cell Prototype Identifiers
* Collection View Cell Prototype Identifiers

## Xcode Plugin

### Installation

#### Alcatraz
```json
AT THE MOMENT ALCATRAZ INSTALLATION IS BROKEN DUE TO ALCATRAZ'S METHOD OF BUILDING AND INSTALLING. 
UNTIL A COMPATIBLE WRAPPER PROJECT CAN BE REWRITTEN PLEASE USE THE MANUAL INSTALLATION STEPS BELOW.
```
The easiest way to get and use **seguecode** is through the wonderful Xcode plugin manager [Alcatraz](http://alcatraz.io/). The **seguecode** plugin, when enabled for a storyboard, will detect when you save your storyboard and automatically regenerate your **seguecode** source code.

#### Manually 
1. Clone the repo
2. Run `git submodule init ; git submodule update`
3. Run `pod install`
4. Open `seguecode.xcworkspace` and build the `seguecodePlugin` scheme
5. Close and reopen Xcode

### Usage
To enable the **seguecode** plugin for a storyboard:

1. Open the storyboard in Xcode
2. Pull down Xcode's *Edit menu* and select the **seguecode** option

![Plugin Screenshot](https://raw.githubusercontent.com/Adorkable/seguecode/master/README/Edit_and_Menubar.png)

This will generate a file alongside your storyboard called *&lt;Storyboard Name&gt;.seguecode.json* which contains configuration information you can change to define how the automatic regeneration works. 

The **seguecode** plugin looks for this json file to see if it should be enabled for a particular storyboard file, deleting it, or unchecking the **seguecode** option in the *Edit menu*, will disable the automatic regeneration.

## Command Line
You can download the [latest release](https://github.com/Adorkable/seguecode/releases/latest)

or 

You can make your own build:

1. Clone the repo
2. Install the appropriate **[cocoapods](http://cocoapods.org)** with `pod install`
3. Build the binary
4. Place it in your favorite location for easy access.

It is recommended that you include a run of **seguecode** in your project as a *Run Script Build Phase* or as an *External Build Target*.

### Exporting
For an accurate list of parameters run `seguecode --help` or `seguecode -h`

The most common usage is

``` Shell
seguecode -o OutputFolder/ ExportMe.storyboard
```

The resulting header and source files will be exported with the same name as your storyboard file. To use them they should be included in your project and your target. 

**Note**: at minimum **seguecode** expects an output location and at least one storyboard file

### Exporting Customization
To further customize your export use the following parameters:

* `-c` or `--combine` - Export the View Controllers combined in one file
* `-p` or `--projectName NAME` - Name to use as project in source file header comment
* `-l` or `--verbose` - Output verbose logging
* `-v` or `--version` - Display **seguecode**'s version
* `-h` or `--help` - Display help

## Preparing your Storyboard
To ensure a proper export please make sure:

* the segue you wish to use has an *Identifier*

For extra clarity and reduced conflicts please make sure:

* the source and destination view controllers have *Storyboard ID*s

### Results

#### Storyboard Identifier
##### TODO

#### Segue Identifier

Your exported header and source files will contain categories with selectors that describe your segue as well as optionally constants that can be used in your view controller ala `self.performSegueWithIdentifier(..., sender: ...)` call.

The resulting selectors and constants will depend on the segue *Identifier* and *Storyboard ID*s you used in your `UIStoryboard`.

For example, if you give your segue the *Identifier* `MyHead`, the source view controller's *Storyboard ID* `Down` and the destination view controller's `MyToes` the results will be:

Easy method calls:

``` Swift
extension MyViewController {
    @IBAction func performDownFromMyHead(sender : AnyObject? = nil)
}    
```

Easy constants:

``` Swift
extension MyViewController {
    struct Segues {
        static let DownFromMyHead
    }
}
```
	
To use the constant directly from your view controller call:

``` Swift
    self.performSegue(MyViewController.Segues.DownFromMyHead, sender: sender)
```

#### Table View Cell Prototype Identifiers
##### TODO

#### Collection View Cell Prototype Identifiers
##### TODO

## Contributing
**seguecode** is a new project that will hopefully continue to grow in usefulness. If you have any ideas or suggestions on how it can better serve you please [create an issue](https://github.com/Adorkable/seguecode/issues/new) labeled *feature* (check to see if the issue exists first please!). Or suggest a  pull request!


## Thanks

Props to **[mogenerator](https://github.com/rentzsch/mogenerator)** for pointing out **[ddcli](https://github.com/ddribin/ddcli)**. And being a CoreData savior. And the kick in the butt to start **seguecode**. 
