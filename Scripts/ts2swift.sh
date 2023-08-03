#!/bin/sh
# ts2swift.sh
# Author: Konrad Figura
# Created: 2023/07/03
# Description: This script converts the TypeScript types to Swift structs

# Usage: ./ts2swift.sh
# Make sure you have "input" folder in the same directory as this script with at least 1 .ts file in it.
# The output will be in the "output" folder.


# Check if "input" folder is present and check if it has at least 1 .ts file
if [ ! -d "input" ] || [ ! "$(ls -A input)" ]; then
    echo "Error: No input folder or input folder is empty"
    exit 1
fi

# Create output folder
if [ ! -d "output" ]; then
    mkdir output
fi

convert_file() {
    filename=$1

    filenameWithoutExtension=$(echo "$filename" | cut -f 1 -d '.')
    # replace "input" with "output"
    filenameWithoutExtension=${filenameWithoutExtension/input/output}

    output="$filenameWithoutExtension.swift"

    # Delete output file if it already exists
    if [ -f "$output" ]; then
        rm "$output"
    fi

    touch "$output"

    # Add the info at the top of the file
    echo "//" >> "$output"
    echo "//  ${filenameWithoutExtension:7}.swift" >> "$output"
    echo "//  Leomard" >> "$output"
    echo "//" >> "$output"
    echo "//  Created automatically by ts2swift on $(date +'%d/%m/%Y')." >> "$output"
    echo "//" >> "$output"
    echo "" >> "$output"
    echo "import Foundation" >> "$output"
    echo "" >> "$output"

    isEditingStruct=false

    initBlock="    init(from decoder: Decoder) throws {\n"
    initBlock="$initBlock        let container = try decoder.container(keyedBy: CodingKeys.self)\n"

    # Read file line by line
    while IFS= read -r line
    do
        # If line starts with "export interface" -> convert it into a struct codable
        if [[ $line == export*interface* ]]; then
            # Get the name of the struct
            structName=$(echo "$line" | cut -f 3 -d ' ')
            echo "struct $structName: Codable {" >> "$output"
            isEditingStruct=true
            continue
        fi

        # If editing a struct
        if [ $isEditingStruct = true ] ; then
            # If in isEditingStruct mode -> convert the variables to swift variables
            # First, remove "_" and capitalise first letter after each "_"

            # Some variables in Lemmy API have "_" at the end and ":"
            # We must preserve it, otherwise decoding the JSON will fail
            variableNameEndsWithUnderscoreAndColon=false
            if [[ $line == *"_:"* ]]; then
                variableNameEndsWithUnderscoreAndColon=true
            fi

            while [[ $line == *"_"* ]]; do
                line=${line//__/_}
                # Get the index of the first "_"
                index=$(echo "$line" | grep -b -o "_" | head -n1 | cut -d: -f1)
                characterAfterUnderscore=${line:$index+1:1}
                characterAfterUnderscore=$(echo "$characterAfterUnderscore" | tr '[:lower:]' '[:upper:]')
                line="${line:0:$index+0}$characterAfterUnderscore${line:$index+2}"
            done

            # Restore the "_" at the end of the variable name
            if [ $variableNameEndsWithUnderscoreAndColon = true ] ; then
                # Replace ":" with "_:"
                line=${line//:/_:}
            fi

            # Remove first 5 characters (empty space)
            line=${line:4}
            # Remove the ";" - Swift doesn't need it
            line=${line%;}

            # Convert "Array" to "[" and "]"
            if [[ $line == *"Array"* ]]; then
                line=${line//Array\</\[}
                line=${line//>/\]}
            fi

            # Convert "number" to "Int"
            if [[ $line == *"number"* ]]; then
                line=${line//number/Int}
            fi

            # Convert "boolean" to "Bool"
            if [[ $line == *"boolean"* ]]; then
                line=${line//boolean/Bool}
            fi

            # Convert "string" to "String"
            if [[ $line == *"string"* ]]; then
                line=${line//string/String}
            fi

            # Convert "PersonId" to "Int"
            if [[ $line == *"PersonId"* ]]; then
                line=${line//PersonId/Int}
            fi

            # Convert "CommunityId" to "Int"
            if [[ $line == *"CommunityId"* ]]; then
                line=${line//CommunityId/Int}
            fi

            # Convert "PostId" to "Int"
            if [[ $line == *"PostId"* ]]; then
                line=${line//PostId/Int}
            fi

            # Convert "CommentId" to "Int"
            if [[ $line == *"CommentId"* ]]; then
                line=${line//CommentId/Int}
            fi

            # Convert "CommentId" to "Int"
            if [[ $line == *"CommentReplyId"* ]]; then
                line=${line//CommentId/Int}
            fi

            # Convert anything "*Id" to "Int"
            if [[ $line == *"*Id"* ]]; then
                line=${line//\*Id/Int}
            fi

            # If the var name is either: when_, published or updated, replace type with Date
            if [[ $line == *"when_"* ]] || [[ $line == *"published"* ]] || [[ $line == *"updated"* ]]; then
                line=${line//String/Date}
            fi

            # If there is "?:", replace it with ":" and add "?" at the end.
            if [[ $line == *"?:"* ]]; then
                line=${line//\?:/:}
                line="$line?"
            fi

            # Add "let" to the beginning of the line
            line="    let $line"

            echo "$line" >> "$output"

            # Add object to init block
            # Get the variable name: remove everything after the first ":"
            variableName=$(echo "$line" | cut -f 1 -d ':')
            # Now remove "var " from the variable name and spaces
            variableName=${variableName//let /}
            variableName=${variableName// /}

            # Get the variable type: remove everything before the first ":"
            variableType=$(echo "$line" | cut -f 2 -d ':')
            # Now remove spaces
            variableType=${variableType// /}

            # If the variable type is Date, then do the following:
            # - Parse it into string object first
            # - Use DateFormatConverter.formatToDate(text: string)

            if [[ $variableType == *"Date"* ]]; then
                # Add the variable to the init block
                if [[ $line == *"? "* ]]; then
                    initBlock="$initBlock        let ${variableName}String = try container.decodeIfPresent(String.self, forKey: .$variableName)\n"
                    initBlock="$initBlock        self.$variableName = ${variableName}String != nil ? DateFormatConverter.formatToDate(text: ${variableName}String) : nil\n"
                else
                    initBlock="$initBlock        let ${variableName}String = try container.decode(String.self, forKey: .$variableName)\n"
                    initBlock="$initBlock        self.$variableName = try DateFormatConverter.formatToDate(from: ${variableName}String)\n"
                fi
            else
                if [[ $line == *"? "* ]]; then
                    # Add the variable to the init block
                    initBlock="$initBlock        self.$variableName = try container.decodeIfPresent($variableType.self, forKey: .$variableName)\n"
                else
                    # Add the variable to the init block
                    initBlock="$initBlock        self.$variableName = try container.decode($variableType.self, forKey: .$variableName)\n"
                fi
            fi
        fi
    done < "$filename"

    # Add the init block
    echo "" >> "$output"

    # Remove last 2 characters from initBlock
    initBlock=${initBlock%??}

    echo "$initBlock" >> "$output"
    echo "    }" >> "$output"

    # Add "}" to the end of the file
    echo "}" >> "$output"

    echo "Created: $output"
}

# Loop through all files in input folder
for filename in input/*.ts; do
    convert_file "$filename"
done

echo "Done!"
echo "Converted $(ls input/*.ts | wc -l) files."
exit 0