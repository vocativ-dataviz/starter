# Project name
Description of what this repo/project is to be used for

# How to deploy
`gulp publish` will push **/build/** to S3

# How to develop
`gulp` will compile coffeescript, stylus, etc and run local webserver

# Deployment checklist
## So you wanna deploy an interactive?
Follow this basic checklist!

- [ ] Has all of the copy been double-checked by Editorial?
- [ ] Is there a link to the data?
    - [ ] The original source?
    - [ ] A cleaned Google Spreadsheet? (Make sure it can't be edited)
- [ ] Share buttons?
    - [ ] Do they link to the correct page?
    - [ ] Do they have good share text/headlines in them?
    - [ ] Does each share button have share images attached with proper proportions?
- [ ] Is the piece deployed correctly?
    - [ ] The slug and host in **options.json** have been double-checked
    - [ ] /build/ has been deployed to S3
    - [ ] Is pym.js installed correctly in the post / CMS?
    - [ ] Is pym enabled properly in the app? (and called after load)
    - [ ] Is the post embed referencing Amazon S3 and *not GitHub*?
- [ ] Have the analytics & testing been set up properly?
    - [ ] Is the GA UA code defined in **options.json**?
    - [ ] Is the GA code set up properly in **mustache/partials/header.mustache**?
    - [ ] Does the page emit **interactive-click** events on click?
    - [ ] Has A/B testing code (VWO) are enabled?
    - [ ] Has usability testing code (Validately or UserTesting) been abled?
    - [ ] Is there a function in the app to trigger **finished-interactive**?
    - [ ] Has Julia been given URL for heatmap click tracking and/or usability testing?
- [ ] Has the data been locked down?
    - [ ] If reporter-driven, have they given final approval?
    - [ ] If running off Google sheets, has it been converted to local JSON/CSV?
- [ ] Is everybody who worked on it credited in some way?
- [ ] Does it work and look right at all screen sizes in the CMS?
    - [ ] Check at 650px (size of CMS desktop column)
    - [ ] Check at 320px (iPhone 3 portrait width)
    - [ ] Check at 1024px (basic desktop size)
    - [ ] What happens when you resize the window between 320 and 1024px?
    - [ ] Do all buttons/animations work on mobile?
- [ ] Has a share/poster image been created? (Large **screenshot.png** of the piece - share images and homepage images)