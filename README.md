# TOWebViewController
#### A view controller for iOS that allows users to quickly view web sites without needing to open Safari/Chrome

![TOWebViewController on iPhone 5](https://raw.github.com/TimOliver/TOWebViewController/master/Screenshots/TOWebViewController.png)

## WTF is this thing?

TOWebViewController is another entry in my "re-inventing-the-wheel" collection for my commercial iOS app, [iComics](http://icomics.co/).
As you can see from the screenshot, TOWebViewController is your standard web view controller designed with the intention of being able to quickly show
the user web content without needing to switch to another app.

## So. Why was it necessary to write a new one from scratch?

While I've already written a couple of web view controllers from scratch for other projects before (Most notably, in [iPokédex](http://www.ubergames.net/projects/ipokedex) ),
they've always been really quick, slapdash implementations that I put together in 5 minutes, that barely fit the job, but were often not really reusable in other projects. 
With iComics, and the myriad number of web enabled features I'm gearing up to add to it, I decided writing a really nice, elegant, flexible one that can handle all of 
my requirements, not to mention would be properly reusable in other projects would be the be the best way to go.

## Features

  * Back refresh buttons, with a forward button that only appears when necessary.
  * PROPER, ACTUAL orientation animations when rotating the device (Check out iOS Chrome, then check out Safari. You'll see what I mean.)
  * A loading bar to indicate current page load progress (using [ninjinkun's amazing algorithm](https://github.com/ninjinkun/NJKWebViewProgress) )
  * An optional action button to allow the user to open the page in Safari (or Chrome) as well as share the URL socially.
  * (TODO) Automatically detect whether being pushed modally, or to a UINavigationController and adjust UI accordingly.
  * (TODO) Implement a confirmation dialog when the web view tries to switch to another app.
  * (TODO) Re-implement the popup that appears when users tap and hold a link for added flexibility.  
  * (TODO) An optional text field for which users may manually enter in a URL
  * (TODO) A proper delegate system to allow external classes to interact with this controller.
  * (TODO) A rudimentary bookmark system.

## License

TOWebViewController is licensed under the MIT License. I don't personally require attribution, but make sure 
to shower [ninjinkun](https://github.com/ninjinkun) with much love for making tracking the page load state possible.

- - -

Copyright 2013 Timothy Oliver. All rights reserved.

Features logic designed by Satoshi Asano (ninjinkun) for NJKWebViewProgress 
(https://github.com/ninjinkun/NJKWebViewProgress), also licensed under the MIT License. 
Re-implemented by Timothy Oliver.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.