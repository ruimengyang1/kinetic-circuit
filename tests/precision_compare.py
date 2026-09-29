"""Compare rehearsed styles. These metrics do not measure human fun or discovery."""
import json
import math
import re
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "artifacts/precision_progression/revision"

def vector(text):
    return tuple(float(n) for n in re.findall(r"-?\d+\.?\d*(?:e[+-]?\d+)?", text))

def analyze(style):
    filename = "expert_flow" if style == "expert" else style
    data = json.loads((OUT / f"route_{filename}.json").read_text())
    assert not data["failures"], data["failures"]
    levels = []
    for result in data["completed"]:
        samples = [t for t in data["trace"] if t["level"] == result["level"] and t["mode"] == "play"]
        total_still = longest_still = current_still = 0
        distance = 0.0
        last = None
        for t in samples:
            point = vector(t["p"])
            if last:
                moved = math.dist(point, last)
                distance += moved
                if moved < 0.15:
                    current_still += 1
                    total_still += 1
                    longest_still = max(longest_still, current_still)
                else:
                    current_still = 0
            last = point
        levels.append({
            "level": result["level"], "seconds": result["seconds"],
            "charges": result["charges"], "hits": result["hits"],
            "rebounds": result["rebounds"], "path_distance": round(distance, 2),
            "stationary_seconds": round(total_still / 60, 3),
            "longest_stationary_seconds": round(longest_still / 60, 3),
            "force_endpoints": [e["can"] for e in result["events"] if e["event"] == "charge endpoint"],
        })
    assert len(levels) == 4
    assert all(c["hits"] == c["rebounds"] == 0 for c in levels)
    return {"levels": levels, "seconds": round(sum(c["seconds"] for c in levels), 2),
            "charges": sum(c["charges"] for c in levels),
            "stationary_seconds": round(sum(c["stationary_seconds"] for c in levels), 3),
            "setup_cycles": sum(max(0, c["charges"] - (3 if c["level"] == 2 else 2)) for c in levels) // 2,
            "first_pass_boardings": sum(n["note"].startswith("board transient first setup") for n in data["notes"])}

result = {"rehearsed_not_human_measurements": True,
          "novice": analyze("novice"), "expert": analyze("expert")}
assert result["expert"]["seconds"] < result["novice"]["seconds"]
assert result["expert"]["charges"] < result["novice"]["charges"]
assert result["expert"]["first_pass_boardings"] == 2
assert all(c["longest_stationary_seconds"] < 2 for style in ("novice", "expert") for c in result[style]["levels"])
(OUT / "comparison.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
