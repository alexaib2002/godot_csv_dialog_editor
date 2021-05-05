# CSV Dialog Editor
<p align="center"><img height="200" src="https://upload.wikimedia.org/wikipedia/commons/f/f0/CSV_Logo.svg"></img></p>

Create CSV-based dialog stories in Godot

## Getting started
There are many dialog editors for Godot, but none of them were based on the <a href="https://docs.godotengine.org/en/stable/getting_started/workflow/assets/importing_translations.html#games-and-internationalization">Godot's Translation System</a>.

The goal of this project is to create an addon that can make localization an easy task while using readable files without dependecies from Godot (no .json / no .tres/res).

The current implementation uses a CSV file as the dialog's source, and generates a Dialog Resource which contains a dialog sequence refering to the keys from your CSV file.

## Installation
To install this plugin, you need to download this project as a ZIP file and extract the addons folder in the root of your project directory. Then, enable it on the Godot's Project Settings menu.

## Making the CSV file
You will need to create and format a CSV file with an spreadsheet editor (ex: LibreOffice Calc, MS Excel...) following the guidelines on the <a href="https://docs.godotengine.org/en/stable/getting_started/workflow/assets/importing_translations.html#translation-format">Translation format guide</a>.
The keys will be composed of two main components, the **AID** (Actor ID) and the **LID** (Line ID). The AID refers to the character or object who will trigger that line. The LID is used for making a different line. It should be incremental. The AID and LID are separated by an _ underscore. 

The key (union of an AID and LID) is called **DID** (Dialog ID).

Stories are composed by multiple DIDs, and they're readed from the first slot to the last one.

The format of your keys should be:
`AID_LID`

Example:

`Actor1_0` Refers to the first line of the dialog of Actor1.

## Sample project
Currently, the sample project is a WIP. Will be available in a few days.

## Roadmap
- [ ] Sample project
### General enhancements
- [ ] Multiple stories inside one resource
- [ ] Dialog tester (reproduce dialog on editor)
- [ ] Preview dialog (press button on slot, and the translation will appear on the preview tab)
### Future scope
- [ ] Multiple dialogs open
- [ ] Add animations (via Tween) (may produce some slowdowns...)

## FAQ
* **Why CSV files?**

CSV files can be edited on any spreadsheet software. This allows the translator to have a better overview of the current translations and their respective keys.
Last, but not least, CSVs are completely independant from Godot, and they're widely used in localization teams.

* **I think I have encountered a bug...**

If you think you have encountered the cause of that bug and you can solve it, feel free to start a pull request, and I will merge it as soon as possible.
Else, create an issue detailing what were you doing when you encountered the bug. Thanks :)
