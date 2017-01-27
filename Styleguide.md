

Indentation and Spacing
------------------------------------------
Use tabs for leading whitespace, spaces everywhere else. Then you can keep your tab width to 2 or 3 or whatever. The project settings are set to use tabs already for every file so you shouldn't need to change your prefs at all.

Vertical blank space is GOOD. Don't cram everything together. 2 empty lines between short methods, 3 if the methods are longer. Same for related types declarations.

Use marks and group related things when files get big.
    // MARK: - Group Name 

Parameters and variable declarations should have a space after the colon.
    var blah: Bool
    func foo(x: Int)



Syntax
------------------------------------------

- Don't declare variable types unless required.
    No:   let blah: String = foo()
    Yes:  let blah = foo()

- Prefer structs over tuples, except no preference for associated values in enums.

- If used, tuples should have labelled members. 

- Do not use "self." unless required

- Do not use parens in if and for statements etc like: if (x) { ...

- Do not explicitly declare enum raw values unless there's a good reason.

