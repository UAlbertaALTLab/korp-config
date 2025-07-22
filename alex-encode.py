import csv
import io
import os

CORPUS_OUTPUT='uhlenbeck.vrt'
CORPUS_TITLE='Uhlenbeck texts'
header0= 'Original Blackfoot Phrase (From Source)'.lower()
header1_candidates = [x.lower() for x in [
    'Blackfoot Word',
    'Blackfoot Word (From Source)'
]]
header2= 'Morpheme Breaks'.lower()
header3= 'Morpheme Gloss'.lower()
header4= 'English Phrase (From Source)'.lower()
header5= 'Notes'.lower()
header6= 'Blackfoot Syllabics - Word (From Source)'.lower()
header7= 'Blackfoot Syllabics - Phrase (From Source)'.lower()

def empty_row(row):
    for item in row:
        if item.strip():
            return False
    return True

def vrt_escape(str):
    return str.replace('&','&amp;').strip().replace(' ','&#x20;').replace('/','&sol;').replace('<','&lt;').replace('>','&gt;').replace('|','&vert;').replace('\n','&NewLine;')

def attr_escape(str):
    return str.replace('"','&quot;').replace('\n','&NewLine;').strip()

def process_file(INPUT_FILE, ID, HAS_DESCRIPTION_IN_HEADERS=True):
    sentences = []
    with open(INPUT_FILE) as f:
        datareader = csv.reader(f)
        source = next(datareader)[0].partition(":")[2] if HAS_DESCRIPTION_IN_HEADERS else next(datareader)[0]
        text = next(datareader)[0].partition(":")[2] if HAS_DESCRIPTION_IN_HEADERS else next(datareader)[0]
        headers = next(datareader)
        current_sentence = []
        for row in datareader:
            if empty_row(row):
                sentences.append(current_sentence)
                current_sentence = []
            else:
                current_sentence.append(row)

    structured_sentences = []

    def cleanup_header(header):
        data = [ x for x in header.split() if x]
        return ' '.join(data).strip().lower()

    for sentence in sentences:
        structured_sentences.append([
            {cleanup_header(headers[index]):output for index,output in enumerate(token) if output.strip()}
            for token in sentence
        ])

    # Sanity check

    structured_sentences = [x for x in structured_sentences if x]
    header1 = [x for x in headers if x.lower().strip() in header1_candidates][0].lower().strip()

        
    for sentence in structured_sentences:
        if len([row for row in sentence if header0 in row.keys()]) != 1:
            print(structured_sentences)
            print("And then it's")
            print(sentence)
            raise ValueError(f"A Sentence does not have a single {header0}")
        if len([row for row in sentence if header4 in row.keys()]) != 1:
            print(f"Warning: Sentence \"{[row for row in sentence if header0 in row.keys()][0][header0]}\" does not have a single {header4}")
        
    # Generate the Korp file then!

    f = io.StringIO()
    f.write(f'<text _id="{ID}" source="{attr_escape(source)}" title="{attr_escape(text)}">\n')
    for index, sentence in enumerate(structured_sentences):
        # print(f"Processing {sentence}")
        original = [row for row in sentence if header0 in row.keys()][0][header0]
        original_syll = [row for row in sentence if header7 in row.keys()]
        original_syll = original_syll[0][header7] if original_syll else ""
        translation_rows = [row for row in sentence if header4 in row.keys()]
        translation = translation_rows[0][header4] if len(translation_rows)>0 else ""
        
        f.write(f'<sentence id="{attr_escape(str(index))}" original="{attr_escape(original)}" translation="{attr_escape(translation)}" original_syll="{attr_escape(original_syll)}">\n')
        for row_index, row in enumerate(sentence):
            f.write(f'{row[header1].strip()}\t{vrt_escape(row[header2]) if header2 in row.keys() else ""}\t{vrt_escape(row[header3]) if header3 in row.keys() else ""}\t{"&NewLine;" if row_index == len(sentence) - 1 else "&nbsp;"}\t{vrt_escape(row[header5]) if header5 in row.keys() else ""}\t{vrt_escape(row[header6]) if header6 in row.keys() else ""}\n')
        f.write('</sentence>\n')
    f.write('</text>\n')

    value = f.getvalue()
    f.close()
    return value

if __name__ == '__main__':
    files = [f for f in os.listdir('corpora_input/') if f.endswith(".csv")]
    files.sort()
    results = []
    for id, file in enumerate(files):
        print(f"Processing {file}...")
        results.append(process_file('corpora_input/'+file, id))
    
    with open(CORPUS_OUTPUT, 'w') as f:
        f.write(f"<corpus title=\"{CORPUS_TITLE}\">\n")
        f.write("\n".join(results))
        f.write("\n</corpus>")