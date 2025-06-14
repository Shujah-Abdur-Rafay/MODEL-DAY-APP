#!/usr/bin/env python3
"""
Script to fix all ui.Input widgets by removing the 'value' parameter
"""

import re
import glob

def fix_input_widgets_in_file(file_path):
    """Fix ui.Input widgets in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Simple pattern to remove value parameter from ui.Input
        # This pattern looks for 'value: something,' and removes it
        pattern = r'(\s*)value:\s*[^,\n]+,(\s*)'

        # Replace all occurrences
        new_content = re.sub(pattern, r'\1', content)

        # Write back if changed
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed: {file_path}")
            return True
        return False

    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """Main function to fix all Dart files"""
    dart_files = glob.glob('lib/**/*.dart', recursive=True)

    fixed_count = 0
    for file_path in dart_files:
        if fix_input_widgets_in_file(file_path):
            fixed_count += 1

    print(f"Fixed {fixed_count} files")

if __name__ == '__main__':
    main()
