# Peev

Peev is a piece of infinite music designed to enhance fortitude and persistence in digital environments. 

It is recommended that you start peev as you are about to embark on a flurry of heterogeneous digital activities. 

Maximum psychological effects are achieved as you forget that peev is in operation.

Peev both needs and does not need you, but your subjectivity is what makes peev real.

# Usage

For the simplest usage, [download the Mac OS app](https://bhobrainey.com/store/44), open it, and click on the image that pops up. For use with [SuperCollider](http://supercollider.github.io/download.html), you will need to have [sc3-plugins](https://github.com/supercollider/sc3-plugins) installed (Windows users can download sc3-plugins from the [SuperCollider download page](http://supercollider.github.io/download.html)). Open peev.scd, put your cursor somewhere in the code, and hit ctrl-return (or follow your platform-specific method for executing SuperCollider code). A window should pop up – hit "Go."

Peev loads three audio files into buffers, and because Document.current is not reliable across platforms, these files may fail to load. To fix, find the following lines and change the paths to absolute paths:
```
sad = Buffer.read(s, Document.current.dir ++ "/audio/sax-bright-01.wav");
melo = Buffer.read(s, Document.current.dir ++ "/audio/sax-bright-02.wav");
voc = Buffer.read(s, Document.current.dir ++ "/audio/voc-01.wav");
```
Becomes:
```
sad = Buffer.read(s, "/your/path/to/audio/sax-bright-01.wav");
melo = Buffer.read(s, "/your/path/to/audio/sax-bright-02.wav");
voc = Buffer.read(s, "/your/path/to/audio/voc-01.wav");
```
(Many versions of the SuperCollider IDE support dragging files into the editor window to reveal their absolute paths, so do that if you're having trouble.)

If you're a Mac user with Cocoa or are using a version of SuperCollider with a GUI that supports Image, you can use the custom interface. As above, you may have to change some paths to absolute:
```
iOff=Image.new(Document.current.dir ++ "/images/ANM026artwork01.jpg");
iOn=Image.new(Document.current.dir ++ "/images/ANM026artwork02.jpg");
```
Becomes:
```
iOff=Image.new("/your/path/to/images/ANM026artwork01.jpg");
iOn=Image.new("/your/path/to/images/ANM026artwork02.jpg");
```

Modify and share. If you care to donate to the peev cause, please [buy the app / code download package](https://bhobrainey.com/store/44).
