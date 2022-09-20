import gzip
import json
from typing import List, Dict, Any

DEFAULT_DIAGNOSE_FILE = "diagnose.json.gz"


def inspect_diagnose_file(diagnose_file: str, sections: List[str] = None):
    sections = sections or ["logs"]
    json_data = _load_diagnose_file(diagnose_file=diagnose_file)

    for section in sections:
        print(f"Displaying `{section}`")
        handler = _section_handlers.get(section)
        content = json_data.get(section)
        handler and handler(content)
        print("---")


def _load_diagnose_file(diagnose_file: str) -> Dict[str, Any]:
    diagnose_file = diagnose_file or DEFAULT_DIAGNOSE_FILE
    with gzip.GzipFile(filename=diagnose_file, mode="rb") as filestream:
        json_data = filestream.read().decode("utf-8")
    json_data = json.loads(json_data)
    return json_data


def print_logs(logs: Dict[str, str]):
    docker_logs = logs.get("docker")
    print(docker_logs)


# maps sections in the diagnose file to action handlers
_section_handlers = {
    "logs": print_logs
}
