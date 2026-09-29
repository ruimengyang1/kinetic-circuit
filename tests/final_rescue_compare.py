"""Input rehearsal measurements, never a proxy for enjoyment or discovery."""
import json
import math
import re
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "artifacts/final_rescue"


def vec(value):
    return tuple(float(n) for n in re.findall(r"-?\d+\.?\d*(?:e[+-]?\d+)?", value))


def analyze(name):
    data = json.loads((OUT / f"route_{name}.json").read_text())
    assert data["input_only"] and not data["failures"]
    levels = []
    starts = []
    for result in data["completed"]:
        samples = [t for t in data["trace"] if t["level"] == result["level"] and t["mode"] == "play"]
        first = samples[0]
        starts.append({k: first[k] for k in ("p", "can", "health", "platforms", "machines")})
        distance = backtrack = 0.0
        still = longest = consecutive = 0
        for old, new in zip(samples, samples[1:]):
            a, b = vec(old["p"]), vec(new["p"])
            moved = math.dist(a, b)
            distance += moved
            backtrack += max(0.0, a[0] - b[0])
            if moved < 0.15:
                still += 1
                consecutive += 1
                longest = max(longest, consecutive)
            else:
                consecutive = 0
        # Observable two useful results in the same charge. This metric does
        # not participate in platform power or exit success.
        dual_impact = 0
        if result["level"] == 2:
            for event in result["events"]:
                if event["event"] == "force":
                    charge = event["charge_id"]
                    related = {e["event"] for e in result["events"] if e["charge_id"] == charge}
                    dual_impact += int("crossing_button on" in related and "button off" in related)
        levels.append({
            "level": result["level"], "seconds": result["seconds"],
            "charges": result["charges"], "hits": result["hits"], "rebounds": result["rebounds"],
            "travel_pixels": round(distance, 2), "leftward_travel_pixels": round(backtrack, 2),
            "stationary_seconds": round(still / 60, 3), "longest_stationary_seconds": round(longest / 60, 3),
            "optional_charges_above_demonstrated_predictive_route": result["charges"] - 2,
            "freeze_return_cycles": result["rotor_state_recreations"],
            "impact_and_next_weight_chains": dual_impact,
            "final_beam_force_weight_chains": result["chained_interactions"],
        })
    assert len(levels) == 4
    assert all(x["hits"] == x["rebounds"] == 0 for x in levels)
    return {
        "levels": levels, "starts": starts,
        "seconds": round(sum(x["seconds"] for x in levels), 2),
        "charges": sum(x["charges"] for x in levels),
        "optional_charges_above_demonstrated_predictive_route": sum(x["charges"] - 2 for x in levels),
        "freeze_return_cycles": sum(x["freeze_return_cycles"] for x in levels),
        "travel_pixels": round(sum(x["travel_pixels"] for x in levels), 2),
        "leftward_travel_pixels": round(sum(x["leftward_travel_pixels"] for x in levels), 2),
        "stationary_seconds": round(sum(x["stationary_seconds"] for x in levels), 3),
        "chained_interactions": sum(x["impact_and_next_weight_chains"] + x["final_beam_force_weight_chains"] for x in levels),
    }


novice = analyze("novice_early_gate")
expert = analyze("expert_flow")
equal_inspection = analyze("expert_flow_equal_inspection")
assert novice["starts"] == expert["starts"] == equal_inspection["starts"]
assert novice["charges"] == 13 and expert["charges"] == equal_inspection["charges"] == 8
assert expert["seconds"] < novice["seconds"] and equal_inspection["seconds"] < novice["seconds"]
assert expert["travel_pixels"] < novice["travel_pixels"]
assert expert["leftward_travel_pixels"] < novice["leftward_travel_pixels"]
assert expert["stationary_seconds"] < novice["stationary_seconds"]
assert expert["chained_interactions"] > novice["chained_interactions"]
assert all(x["longest_stationary_seconds"] < 2 for style in (novice, expert) for x in style["levels"])
for style in (novice, expert, equal_inspection):
    style.pop("starts")
recovery = json.loads((OUT / "planning_recovery.json").read_text())
assert not recovery["failures"]
result = {
    "rehearsed_not_human_measurements": True,
    "identical_room_start_states": True,
    "novice": novice, "expert": expert, "expert_equal_inspection": equal_inspection,
    "separate_actual_mistake_recovery": {"input_only": True, "level": 2, "charges": recovery["metrics"]["charges"], "corrective_charges": 2},
    "interpretation": "Optional preparation cycles are conservative choices, not fabricated mistakes. Correction is measured in a separate input-only mistake run. Stationary time is a position measure, not proof of meaningless waiting.",
}
(OUT / "comparison.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
