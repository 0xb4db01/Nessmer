## Nessmer - A Nessus report merge tool

Author: 0xb4db01

Date: 09/09/2022

Description: This: https://github.com/0xprime/NessusReportMerger but in Nim.

Merges Nessus reports into one final report.

Compile

```
nim c -d:release nessmer.nim
```

Run

```
./nessmer -i=<input directory> -o=<output file name>
```

input directory is where you want to put all your .nessus xml files.

Note that the final report's name in Nessus UI when imported will be the chosen output file name without the .nessus extension.
