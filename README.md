orgiami.rb is a Ruby script that transforms ASCII art directory structures into real file systems. It takes an indented, tree-style text representation of folders and files (like those output by the tree command) and creates the actual directories and files on your system.

The script is clever enough to:

- Parse indentation levels to determine nesting
- Handle both folders and files correctly
- Strip away comments from file names
- Support different input methods (file, STDIN, or interactive mode)

Think of it as a "directory structure interpreter" that reads your ASCII art folder map and folds it into reality, just like origami transforms a flat sheet of paper into a three-dimensional object. It's particularly useful for quickly scaffolding project structures without having to manually create each directory and file.

## Example

gem/
  ├── Gemfile
  ├── lib/
  │   ├── gem.rb
  │   ├── gem/
  │   │   ├── foo.rb
  │   │   ├── bar.rb
  │   │   ├── daz.rb # Lorem Ipsum Dolores
  │   │   └── models/
  │   │       ├── foo.rb
  │   │       ├── bar.rb
  │   │       └── daz.rb # Lorem Ipsum Dolores
  ├── spec/
  │   └── gem.rb
  └── README.md