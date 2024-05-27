import collections
import io
import zstandard
import json
import itertools as I
import fire
import os
from pathlib import Path

EXCLUDE_CATEGORIES = {
    # See http://dsi.ut-capitole.fr/blacklists/index_en.php
    "agressif",
    "adult",
    "cryptojacking",
    "dangerous_material",
    "phishing",
    "warez",
    "ddos",
    "hacking",
    "malware",
    "mixed_adult",
    "sect",
}
OSCAR_MIN_HARMFUL_PP = 5.0
OSCAR_MAX_HARMFUL_PP = 100_000.0

def filter_oscar(meta):
    categories = set(meta.get('categories', None) or [])
    f1 = not categories.intersection(EXCLUDE_CATEGORIES)
    
    harmful_pp = meta.get('harmful_pp', None) or OSCAR_MAX_HARMFUL_PP
    f2 = (OSCAR_MIN_HARMFUL_PP < harmful_pp < OSCAR_MAX_HARMFUL_PP)

    f3 = not bool(meta.get('quality_warnings', []))
    return all([f1, f2, f3])

def generate_samples(doc_path):
    id_ = 0
    with open(doc_path, "rb") as fh:
        dctx = zstandard.ZstdDecompressor()
        stream_reader = dctx.stream_reader(fh)
        buffered_reader = io.BufferedReader(stream_reader)
        text_stream = io.TextIOWrapper(buffered_reader, encoding="utf-8")
        for line in text_stream:
            doc = json.loads(line)
            meta = doc["metadata"]
            meta["warc_headers"] = doc["warc_headers"]

            try:
                meta["warc_headers"]["warc-identified-content-language"]
            except KeyError:
                meta["warc_headers"]["warc-identified-content-language"] = None

            if filter_oscar(meta):
                yield id_, doc
                id_ += 1


def main(src, dst):
    os.makedirs(Path(dst).parent, exist_ok=True)

    cctx = zstandard.ZstdCompressor()
    with open(dst, 'wb') as fh:
        with cctx.stream_writer(fh) as compressor:
            for _, doc in generate_samples(src):
                jsonl = json.dumps(doc).encode('utf-8')
                compressor.write(jsonl)
                compressor.write(b"\n")
        
if __name__ == "__main__":
    fire.Fire(main)