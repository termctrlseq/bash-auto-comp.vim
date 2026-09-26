# bash-auto-comp.vim
Bash completion source for [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)

## Installing

```bash
mkdir -p ~/.vim/pack/bash-auto-comp.vim/start
cd ~/.vim/pack/bash-auto-comp.vim/start
git clone https://github.com/termctrlseq/bash-auto-comp.vim
```

## Register asyncomplete-file.vim

```vim
au User asyncomplete_setup call asyncomplete#register_source({
      \     'name': 'bash_auto_comp',
      \     'allowlist': ['sh', 'bash'],
      \     'completor': function('bash_auto_comp#completor')
      \ })
```
