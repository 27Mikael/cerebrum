import re
from pathlib import Path

def file_walker_inator(root: Path, max_depth: int = 4):
    """
        walk the through knowledgebase_dir, identify files at 

    """
    def recurse_inator(path: Path, parts: list[str]):
        for file in path.glob("*"):
            if file.is_file():
                yield {
                    "domain": parts[0] if len(parts) > 0 else None,
                    "subject": parts[1] if len(parts) > 1 else None,
                    "topic": parts[2] if len(parts) > 2 else None,
                    "subtopic": parts[3] if len(parts) > 3 else None,
                    "filepath": file,
                    "filename": file.name,
                    "filestem": file.stem,
                    "file-ext": file.suffix
                }
            elif file.is_dir() and len(parts) < max_depth:
                yield from recurse_inator(file, parts + [file.name])

    yield from recurse_inator(root, [])


UUID_PATTERN = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")

def knowledgebase_index_inator(root: Path):
    domains, subjects, topics, subtopics = set(), set(), set(), set()
    available_files = []

    for info in file_walker_inator(root):
        # skip if any part is a UUID
        skip = False
        for part in [info["domain"], info["subject"], info["topic"], info["subtopic"]]:
            if part and UUID_PATTERN.fullmatch(part):
                skip = True
                break
        if skip:
            continue

        available_files.append(info)
        if info["domain"]: domains.add(info["domain"])
        if info["subject"]: subjects.add(info["subject"])
        if info["topic"]: topics.add(info["topic"])
        if info["subtopic"]: subtopics.add(info["subtopic"])

    return {
        "domains": sorted(domains),
        "subjects": sorted(subjects),
        "topics": sorted(topics),
        "subtopics": sorted(subtopics),
    }

