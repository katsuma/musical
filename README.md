# musical [![Build Status](https://travis-ci.org/katsuma/musical.png?branch=master)](https://travis-ci.org/katsuma/musical) [![Coverage Status](https://coveralls.io/repos/katsuma/musical/badge.png)](https://coveralls.io/r/katsuma/musical)

`musical` is a simple tool for your favorite music DVD.
You can rip vob file by DVD chapter, convert it to wav file and add it to your iTunes library.


## Install

`musical` depends on `dvdbackup` and `ffmpeg`.
To install them try this for example,

```sh
brew install dvdbackup
brew install ffmpeg
```

And install gem.

```sh
gem install musical
```


## Usage
Set your DVD and type

```sh
musical <options>
```

Options:
```sh
                  --info, -i:   Show your DVD data
  --ignore-convert-sound, -g:   Rip data only, NOT convert them to wav file
     --ignore-use-itunes, -n:   NOT add ripped files to iTunes and encode them
               --dev, -d <s>:   Set location of DVD device
             --title, -t <s>:   Set DVD title (default: LIVE)
            --artist, -a <s>:   Set DVD artist (default: Artist)
            --output, -o <s>:   Set location of ripped data (default: ripped)
               --version, -v:   Print version and exit
                  --help, -h:   Show this message
```

When you use iTunes, you should use `--title` and `--artist` options.
They will help you to manage your music library easily.


## Supported OS
- OSX 10.8 (Mountain Lion)

## Supported Ruby
- 2.0.0
- 1.9.3


## License

musical is released under the MIT License.
