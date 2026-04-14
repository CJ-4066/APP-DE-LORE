#!/usr/bin/env python3
from __future__ import annotations

import argparse
import html
import json
import re
import time
from collections import Counter
from io import BytesIO
from pathlib import Path
from typing import Any
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from pypdf import PdfReader

ENTRY_RE = re.compile(
    r'\[\[null,"([^"]+)"\],null,null,null,"([^"]+)".{0,2000}?\[\[\["([^"]+)",null,true\]\]\]',
    re.DOTALL,
)
TITLE_RE = re.compile(r"<title>(.*?) - Google Drive</title>", re.DOTALL)
STOPWORDS = {
    "de",
    "la",
    "el",
    "los",
    "las",
    "y",
    "o",
    "u",
    "en",
    "del",
    "al",
    "que",
    "se",
    "su",
    "sus",
    "para",
    "por",
    "con",
    "sin",
    "una",
    "un",
    "uno",
    "unas",
    "unos",
    "como",
    "más",
    "mas",
    "sobre",
    "desde",
    "este",
    "esta",
    "estos",
    "estas",
    "entre",
    "pero",
    "porque",
    "todo",
    "toda",
    "todos",
    "todas",
    "and",
    "the",
    "for",
    "with",
    "from",
    "that",
    "this",
    "your",
    "you",
    "are",
    "was",
    "were",
}


def fetch_text(url: str) -> str:
    request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=60) as response:
        return response.read().decode("utf-8", "ignore")


def fetch_bytes(url: str) -> bytes:
    request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=120) as response:
        return response.read()


def normalize_whitespace(value: str) -> str:
    return re.sub(r"[ \t]+", " ", value).replace("\r", "").strip()


def tokenize(value: str) -> list[str]:
    normalized = (
        value.lower()
        .replace("á", "a")
        .replace("é", "e")
        .replace("í", "i")
        .replace("ó", "o")
        .replace("ú", "u")
        .replace("ñ", "n")
    )
    tokens = re.findall(r"[a-z]{3,}", normalized)
    return [token for token in tokens if token not in STOPWORDS]


def build_chunks(text: str, max_chars: int = 1400, overlap: int = 220) -> list[str]:
    clean = re.sub(r"\n{3,}", "\n\n", normalize_whitespace(text.replace("\n", "\n")))
    paragraphs = [part.strip() for part in clean.split("\n\n") if part.strip()]
    if not paragraphs:
        return []

    chunks: list[str] = []
    current = ""
    for paragraph in paragraphs:
        candidate = f"{current}\n\n{paragraph}".strip() if current else paragraph
        if len(candidate) <= max_chars:
            current = candidate
            continue
        if current:
            chunks.append(current)
        if len(paragraph) <= max_chars:
            current = paragraph
            continue
        start = 0
        while start < len(paragraph):
            end = min(len(paragraph), start + max_chars)
            piece = paragraph[start:end].strip()
            if piece:
                chunks.append(piece)
            if end >= len(paragraph):
                break
            start = max(0, end - overlap)
        current = ""
    if current:
        chunks.append(current)

    dedup: list[str] = []
    seen = set()
    for chunk in chunks:
        key = chunk[:120]
        if key in seen:
            continue
        seen.add(key)
        dedup.append(chunk)
    return dedup


def summarize_text(text: str) -> str:
    paragraphs = [
        part.strip()
        for part in re.split(r"\n{2,}", text)
        if len(part.strip()) >= 120
    ]
    if paragraphs:
        return " ".join(paragraphs[:2])[:1200]
    return normalize_whitespace(text)[:1200]


def top_terms(text: str, limit: int = 12) -> list[str]:
    counts = Counter(tokenize(text))
    return [word for word, _ in counts.most_common(limit)]


def extract_entries(html_text: str) -> list[dict[str, Any]]:
    decoded = html.unescape(html_text)
    local_seen = set()
    entries: list[dict[str, Any]] = []
    for match in ENTRY_RE.finditer(decoded):
        item_id, mime, title = match.groups()
        if mime not in ("application/pdf", "application/vnd.google-apps.folder"):
            continue
        if item_id in local_seen:
            continue
        local_seen.add(item_id)
        entries.append(
            {
                "id": item_id,
                "mime": mime,
                "title": title,
            }
        )
    return entries


def extract_folder_title(html_text: str, fallback: str) -> str:
    decoded = html.unescape(html_text)
    match = TITLE_RE.search(decoded)
    if not match:
        return fallback
    title = normalize_whitespace(match.group(1))
    return title or fallback


def download_pdf(pdf_id: str) -> bytes:
    query = urlencode({"export": "download", "id": pdf_id})
    url = f"https://drive.google.com/uc?{query}"
    payload = fetch_bytes(url)
    if payload.startswith(b"<!DOCTYPE html") or payload.startswith(b"<html"):
        raise RuntimeError("Google Drive devolvio HTML en vez de PDF.")
    return payload


def extract_pdf_text(payload: bytes) -> tuple[int, str]:
    reader = PdfReader(BytesIO(payload))
    pages = len(reader.pages)
    text_parts: list[str] = []
    for page in reader.pages:
        extracted = page.extract_text() or ""
        if extracted.strip():
            text_parts.append(extracted)
    return pages, "\n\n".join(text_parts)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root-folder-id", required=True)
    parser.add_argument(
        "--output",
        default="data/knowledge/drive-corpus.json",
    )
    parser.add_argument(
        "--cache-dir",
        default="data/knowledge/cache",
    )
    parser.add_argument("--max-docs", type=int)
    parser.add_argument("--flush-every", type=int, default=5)
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parents[1]
    output_path = project_root / args.output
    cache_dir = project_root / args.cache_dir
    pdf_cache_dir = cache_dir / "pdfs"
    html_cache_dir = cache_dir / "html"
    pdf_cache_dir.mkdir(parents=True, exist_ok=True)
    html_cache_dir.mkdir(parents=True, exist_ok=True)

    queue: list[dict[str, Any]] = [
        {
            "id": args.root_folder_id,
            "parent_id": None,
            "depth": 0,
            "path": [],
            "title": "ROOT",
        }
    ]
    seen_folders: set[str] = set()
    folders: list[dict[str, Any]] = []
    pdf_entries: list[dict[str, Any]] = []

    while queue:
        folder = queue.pop(0)
        folder_id = folder["id"]
        if folder_id in seen_folders:
            continue
        seen_folders.add(folder_id)

        folder_url = f"https://drive.google.com/drive/folders/{folder_id}"
        html_path = html_cache_dir / f"{folder_id}.html"
        if html_path.exists():
            html_text = html_path.read_text()
        else:
            html_text = fetch_text(folder_url)
            html_path.write_text(html_text)

        actual_title = extract_folder_title(html_text, folder["title"])
        current_path = folder["path"] + [actual_title]
        entries = extract_entries(html_text)

        folders.append(
            {
                "id": folder_id,
                "parent_id": folder["parent_id"],
                "title": actual_title,
                "depth": folder["depth"],
                "path": current_path,
                "url": folder_url,
                "entry_count": len(entries),
            }
        )

        for entry in entries:
            if entry["mime"] == "application/vnd.google-apps.folder":
                queue.append(
                    {
                        "id": entry["id"],
                        "parent_id": folder_id,
                        "depth": folder["depth"] + 1,
                        "path": current_path,
                        "title": entry["title"],
                    }
                )
                continue

            pdf_entries.append(
                {
                    "id": entry["id"],
                    "title": entry["title"],
                    "mime": entry["mime"],
                    "folder_id": folder_id,
                    "folder_title": actual_title,
                    "folder_path": current_path,
                    "download_url": f"https://drive.google.com/uc?export=download&id={entry['id']}",
                }
            )

    documents: list[dict[str, Any]] = []
    chunks: list[dict[str, Any]] = []

    def write_snapshot() -> None:
        corpus = {
            "version": "0.1.0",
            "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "source": {
                "type": "google_drive_public_folder",
                "root_folder_id": args.root_folder_id,
                "root_folder_url": f"https://drive.google.com/drive/folders/{args.root_folder_id}",
            },
            "stats": {
                "folder_count": len(folders),
                "document_count": len(documents),
                "chunk_count": len(chunks),
                "queued_pdf_count": len(pdf_entries),
            },
            "folders": folders,
            "documents": documents,
            "chunks": chunks,
        }
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(
            json.dumps(corpus, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    write_snapshot()

    for index, pdf in enumerate(pdf_entries, start=1):
        if args.max_docs is not None and len(documents) >= args.max_docs:
            break

        pdf_path = pdf_cache_dir / f"{pdf['id']}.pdf"
        try:
            if pdf_path.exists():
                payload = pdf_path.read_bytes()
            else:
                payload = download_pdf(pdf["id"])
                pdf_path.write_bytes(payload)

            page_count, text = extract_pdf_text(payload)
            if not text.strip():
                continue

            doc_summary = summarize_text(text)
            doc_terms = top_terms(text)
            document = {
                **pdf,
                "page_count": page_count,
                "file_size_bytes": len(payload),
                "text_length": len(text),
                "summary": doc_summary,
                "top_terms": doc_terms,
            }
            documents.append(document)

            for chunk_index, chunk_text in enumerate(build_chunks(text), start=1):
                chunks.append(
                    {
                        "id": f"{pdf['id']}::{chunk_index}",
                        "document_id": pdf["id"],
                        "order": chunk_index,
                        "folder_title": pdf["folder_title"],
                        "folder_path": pdf["folder_path"],
                        "title": pdf["title"],
                        "keywords": top_terms(chunk_text, limit=8),
                        "text": chunk_text,
                    }
                )

            print(
                f"[{index}/{len(pdf_entries)}] OK {pdf['folder_title']} :: {pdf['title']} "
                f"pages={page_count} chars={len(text)}",
                flush=True,
            )
            if len(documents) % max(args.flush_every, 1) == 0:
                write_snapshot()
        except Exception as error:
            print(f"[{index}/{len(pdf_entries)}] FAIL {pdf['title']} :: {error}", flush=True)

    write_snapshot()
    print(f"WROTE {output_path}", flush=True)


if __name__ == "__main__":
    main()
