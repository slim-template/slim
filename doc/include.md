# Include

The include plugin allows Slim templates to include other files. The .slim extension is appended automatically to the
filename. If the included file is not a Slim file, it is interpreted as a text file with `#{interpolation}`.

Example:

    include partial.slim
    include partial
    include partial.txt

Relative paths in an included Slim template are resolved from that template's directory, so nested includes can refer to sibling files.

Enable the include plugin with

    require 'slim/include'

# Options

| Type | Name | Default | Purpose |
| ---- | ---- | ------- | ------- |
| Array | :include_dirs | [Dir.pwd, '.'] | Directories where to look for the files |
