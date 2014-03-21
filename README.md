# seguecode
**seguecode** is a support tool to use alongside `UIStoryboard` development. It provides compile-time (and eventually run-time) safeties around dealing with `UIStoryboard`s in an effort to create an error free workflow so you can focus on the important things.

## Installation
Currently **seguecode** does not have an installation process, the only way to use it is to

1. Clone the repo
2. Install the appropriate **[cocoapods](http://cocoapods.org)** with `pod install`
3. Build the binary
4. Place it in your favorite location for easy access.

It is recommended that you include a run of **seguecode** in your project as a *Run Script Build Phase* or as an *External Build Target*.


## Usage
To ensure a proper export please make sure:

* the segue you wish to use has an *Identifier*

For extra clarity and reduced conflicts please make sure:

* the source and destination view controllers have *Storyboard ID*s

### Exporting
For an accurate list of parameters run `seguecode --help` or `seguecode -h`

The most common usage is

``` Shell
seguecode -o OutputFolder/ ExportMe.storyboard
```

The resulting header and source files will be exported with the same name as your storyboard file. To use them they should be included in your project and your target. 

**Note**: at minimum **seguecode** expects an output location and at least one storyboard file

### Coding
Your exported header and source files will contain categories with selectors that describe your segue as well as optionally constants that can be used in your `[viewController performSegueWithIdentifier:sender:]` call.

The resulting selectors and constants will depend on the segue *Identifier* and *Storyboard ID*s you used in your `UIStoryboard`.

For example, if you give your segue the *Identifier* `MyHead`, the source view controller's *Storyboard ID* `Down` and the destination view controller's `MyToes` the results will be

``` Objective-C
- (IBAction)segueDownFromMyHead;
- (void)segueDownFromMyHeadWithInfo:(id)info;
```

``` Objective-C 
NSString * const FromMyHeadDownToMyToes;
```
	
To use the constant simply include the header and call

``` Objective-C
[myHeadInstance performSegueWithIdentifier:FromMyHeadDownToMyToes sender:info];
```
	
Xcode's autocorrect should help you out and fill in the name.

### Exporting Customization
To further customize your export use the following parameters:

* `-s` or `--squash-vcs` - Store all UIViewController and subclass categories in one file
* `-c` or `--export-constants` - Include segue ID constants in the header for direct usage
* `-v` or `--version` - Display **seguecode**'s version
* `-h` or `--help` - Display help

## Contributing
**seguecode** is a new project that will hopefully continue to grow in usefulness. If you have any ideas or suggestions on how it can better serve you please [create an issue](https://github.com/yoiang/seguecode/issues/new) labeled *feature* (check to see if the issue exists first please!). Or suggest a  pull request!


## Thanks
Props to 

* **[ddcli](https://github.com/ddribin/ddcli)**
* **[RaptureXML](https://github.com/ZaBlanc/RaptureXML)**
* **[CCTemplate](https://github.com/xhan/CocoaTemplateEngine)**


Props to **[mogenerator](https://github.com/rentzsch/mogenerator)** for pointing out **[ddcli](https://github.com/ddribin/ddcli)**. And being a CoreData savior. And the kick in the butt to start **seguecode**. 