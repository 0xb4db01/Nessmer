##
# Nessmer - A Nessus report merge tool
# Author: 0xb4db01
# Date: 09/09/2022
# Description: This [https://github.com/0xprime/NessusReportMerger] but in Nim.
# 
# Merges Nessus reports into one final report.
# Compile: nim c -d:release nessmer.nim
# Run: ./nessmer -i=<input directory> -o=<output file name>
#
# input_directory is where you want to put all your .nessus xml files.
# Note that the final report's name in Nessus UI when imported will be the 
# chosen output file name without the .nessus extension.
#

import os
import std/strutils
import std/parseopt
import std/xmltree
import std/xmlparser

proc helpUsage(): void =
    echo "arguments: -i=<input directory> -o=<output_file>"

    quit()

let cmdLineStr = join(commandLineParams(), " ")

if cmdLineStr == "":
    helpUsage()

var cmdLineP = initOptParser(cmdLineStr)

var inputDir = ""
var outputFileName = ""

while true:
    cmdLineP.next()

    case cmdLineP.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
        if cmdLineP.val == "":
            continue
        else:
            if cmdLineP.key == "i":
                inputDir = cmdLineP.val

                continue
            if cmdLineP.key == "o":
                outputFileName = cmdLineP.val

                continue
    of cmdArgument:
        continue

if inputDir == "" or outputFileName == "":
    helpUsage()

##
# Add the .nessus extension if the user didn't
#
if outputFileName.split(".nessus").len < 2:
    outputFileName &= ".nessus"

##
# Will be set to true as soon as the first nessus file is parsed
#
var is_first: bool = false

##
# The final merged Nessus report
#
var outfile_content: XmlNode

##
# We walk in the given directory, parse the first file and store it in
# outfile_content, read all the other files and merge the ReportHost
# elements in outfile_content
#
for kind, path in walkDir(inputDir):
    echo path

    var doc: XmlNode

    try:
        doc = loadXml(path)
    except XmlError:
        echo "Error: invalid XML in ", path

        continue

    if is_first == false:
        outfile_content = parseXml($doc)

        # now we got our first file, time to merge...
        is_first = true
    else:
        # merging...
        var elem = doc.findAll("ReportHost")

        for e in elem:
            outfile_content.add e

##
# Set report name for Nessus UI
#
let attributes = {
    "xmlns:cm": outfile_content.findAll("Report")[0].attr("xmlns:cm"),
    "name": outputFileName.split(".")[0]
}.toXmlAttributes

outfile_content.findAll("Report")[0].attrs = attributes

##
# Finally, we save our merged report
# 
var f = open(outputFileName, fmWrite)

f.write(outfile_content)

f.close()

echo "Done..."
