import json
import os
import re
import shutil
from collections import defaultdict

def sanitize_filename(name):
    """
    Sanitize the filename by replacing or removing invalid characters.
    """
    # Replace spaces with underscores
    name = name.replace(' ', '_')
    # Remove any character that is not alphanumeric, underscore, or hyphen
    name = re.sub(r'[^\w\-]', '', name)
    return name

def clear_output_directory(output_dir):
    """
    Clears the output directory by deleting all its contents.
    
    :param output_dir: Path to the output directory.
    """
    if os.path.exists(output_dir):
        # Remove all files and subdirectories in the output directory
        for filename in os.listdir(output_dir):
            file_path = os.path.join(output_dir, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)  # Remove file or link
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)  # Remove directory
            except Exception as e:
                print(f"Failed to delete {file_path}. Reason: {e}")
    else:
        # Create the directory if it does not exist
        os.makedirs(output_dir, exist_ok=True)

def transform_json(input_file, output_dir):
    """
    Transforms the input JSON into multiple chapter-wise JSON files.
    Clears the output directory first and provides a detailed summary of transformations.

    :param input_file: Path to the input JSON file.
    :param output_dir: Directory where output JSON files will be saved.
    """
    # Clear the output directory
    print(f"Clearing the output directory: '{output_dir}'")
    clear_output_directory(output_dir)
    print("Output directory cleared.\n")

    # Read the input JSON data with utf-8-sig encoding to handle BOM
    try:
        with open(input_file, 'r', encoding='utf-8-sig') as f:
            books = json.load(f)
    except FileNotFoundError:
        print(f"Error: The file '{input_file}' does not exist.")
        return
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
        return

    # Initialize a summary dictionary
    summary = defaultdict(lambda: {"chapters": 0, "total_verses": 0, "chapters_detail": {}})

    # Iterate through each book in the JSON
    for book in books:
        book_name = book.get('name', 'UnknownBook')
        chapters = book.get('chapters', [])

        # Iterate through each chapter
        for chapter_index, chapter in enumerate(chapters, start=1):
            verses = chapter  # List of verses in the chapter
            verse_objects = []

            # Iterate through each verse
            for verse_index, verse in enumerate(verses, start=1):
                title = f"{book_name}:{chapter_index}:{verse_index}"
                verse_obj = {
                    "Title": title,
                    "Content": verse,
                    "Url": "https://wol.jw.org/es/wol/binav/r4/lp-s/nwtsty"
                }
                verse_objects.append(verse_obj)

            # Define the output filename
            sanitized_book_name = sanitize_filename(book_name)
            output_filename = f"{sanitized_book_name}_{chapter_index}.json"
            output_path = os.path.join(output_dir, output_filename)

            # Write the verse objects to the JSON file
            try:
                with open(output_path, 'w', encoding='utf-8') as outfile:
                    json.dump(verse_objects, outfile, ensure_ascii=False, indent=4)
                print(f"Created '{output_filename}' with {len(verse_objects)} verses.")
                
                # Update summary
                summary[book_name]["chapters"] += 1
                summary[book_name]["total_verses"] += len(verse_objects)
                summary[book_name]["chapters_detail"][chapter_index] = len(verse_objects)
            except IOError as e:
                print(f"Error writing to file '{output_filename}': {e}")

    # Print the summary surrounded by separators
    separator = "=" * 50
    print(f"\n{separator}")
    print("Transformation Summary:")
    print(separator)

    total_books = len(summary)
    total_chapters = sum(book["chapters"] for book in summary.values())
    total_verses = sum(book["total_verses"] for book in summary.values())

    print(f"Total Books Processed   : {total_books}")
    print(f"Total Chapters Processed: {total_chapters}")
    print(f"Total Verses Transformed: {total_verses}\n")

    for book, data in summary.items():
        print(f"Book: {book}")
        print(f"  Chapters: {data['chapters']}")
        print(f"  Total Verses: {data['total_verses']}")
        for chapter_num in sorted(data["chapters_detail"]):
            verses_count = data["chapters_detail"][chapter_num]
            print(f"    Chapter {chapter_num}: {verses_count} verses")
        print()  # Add an empty line between books

    print(separator)
    print("All transformations completed successfully.")
    print(separator)

if __name__ == "__main__":
    input_json_file = 'assets/es_rvr.json'        
    output_directory = 'data'                      
    transform_json(input_json_file, output_directory)
