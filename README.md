# vim-fold-one package

This is an [Atom](https://atom.io) package to manage folds of the first
indentation level in source code files. Movement as being realized by this
package does not make a lot of sense in every single case. Folding itself needs
to be done wisely. A little ranty but partially very valid blog post about
folding can be found here:
https://blog.codinghorror.com/the-problem-with-code-folding.

This plugin is intended to be used with https://atom.io/packages/vim-mode-plus.
To make this package properly work you need to define your key mappings first.
The following key mappings are defined by default but do not work out of the box
because of interferences with `vim-mode-plus`. In case you have issues sorting
out the key mappings to make this plugin work you can check your key bindings
using the key binding resolver which can be invoked using `cmd-.` on OSX.

```
'atom-text-editor.vim-mode-plus:not(.insert-mode)':
  'ctrl-k': 'vim-fold-one:move-up'
  'ctrl-j': 'vim-fold-one:move-down'
  'ctrl-f': 'vim-fold-one:toggle-current-fold'
  'ctrl-c': 'vim-fold-one:toggle-all-folds'
```
