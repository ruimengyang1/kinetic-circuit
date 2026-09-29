"""Compare rehearsed choices; annotations describe these routes, not player intent."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "artifacts/level_progression/revision2"


def load_levels(path):
    data = json.loads((EVIDENCE / path).read_text())
    assert not data["failures"], (path, data["failures"])
    return {row["level"]: row for row in data["completed"]}


def summarize(row, corrective_ids=(), unnecessary_ids=(), avoidable_ids=(), decisions=1):
    events = row["events"]
    charges = {e["charge_id"] for e in events if e["event"] == "charge"}
    assert set(corrective_ids).issubset(charges)
    assert set(unnecessary_ids).issubset(charges)
    assert set(avoidable_ids).issubset(charges)
    return {
        "seconds": row["seconds"],
        "charges": row["charges"],
        "unnecessary_can_charges_annotated": len(unnecessary_ids),
        "unnecessary_charge_ids": list(unnecessary_ids),
        "corrective_repositionings_annotated": len(corrective_ids),
        "corrective_charge_ids": list(corrective_ids),
        "avoidable_charges_relative_to_prepared_order": len(avoidable_ids),
        "avoidable_charge_ids": list(avoidable_ids),
        "useful_cover_losses": row["useful_cover_losses"],
        "rotor_state_recreations": row["rotor_state_recreations"],
        "chained_interactions": row["chained_interactions"],
        "meaningful_order_decisions_annotated": decisions,
        "hits": row["hits"],
        "rebounds": row["rebounds"],
        "endpoints": [e["can"] for e in events if e["event"] == "charge endpoint"],
    }


sequential = load_levels("route_sequential.json")
prepared = load_levels("route_expert.json")
right = load_levels("right/route_sequential_L3.json")[3]
assert sequential[4]["charges"] == 4 and prepared[4]["charges"] == 2
assert sequential[4]["boulder_impacts"] == 2 and prepared[4]["boulder_impacts"] == 1
assert prepared[4]["chained_interactions"] == 1
assert sequential[4]["chained_interactions"] == 0
assert sequential[2]["boulder_impacts"] == 1 and prepared[2]["boulder_impacts"] == 0
assert sequential[2]["useful_cover_losses"] == 1 and prepared[2]["useful_cover_losses"] == 0
assert sequential[3]["rebounds"] == 0 and right["rebounds"] >= 1

comparison = {
    "evidence_type": "same-spawn, authored input-only strategies; not observed novice/expert people",
    "annotation_rules": {
        "unnecessary": "No whole charge is redundant in these routes given its current state. Early-air charge 4 re-hits already-cleared Boulder, but is necessary to withdraw Can in that state. Do not count the whole charge as useless.",
        "avoidable": "Early-air charges 3 and 4 are absent in the prepared order. This contextual comparison is separate from unnecessary charges.",
        "corrective": "Early-air charge 3 returns Can to control after the premature withdrawal; charge 4 finishes that corrected setup. The common first right charge parks Can intentionally.",
        "chains": "A single charge must withdraw from an aligned rotor AND transfer force AND actually open previously blocked air. Re-hitting an already-cleared Boulder does not count.",
        "decisions": "one tested branch per compared state, manually annotated; not a count of inputs or hesitations",
        "cover": "A loss can be deliberate. In L4 the rotating beam leaves Boulder cover during aiming, before Boulder moves. Preserved state in the shared choice is rotor occupancy, not uninterrupted cover.",
    },
    "level_2_same_spawn": {
        "spend_cover_open_upper_route": summarize(sequential[2]),
        "preserve_cover_open_ground_route": summarize(prepared[2]),
    },
    "level_3_same_spawn": {
        "left_withdrawal": summarize(sequential[3]),
        "right_withdrawal": summarize(right),
    },
    "level_4_same_spawn": {
        "early_air_then_restore_control": summarize(sequential[4], corrective_ids=(3,), avoidable_ids=(3, 4)),
        "preserve_rotation_then_chain": summarize(prepared[4]),
    },
    "known_solution_totals_seconds_excluding_transitions": {
        "separate_steps": round(sum(row["seconds"] for row in sequential.values()), 2),
        "prepared": round(sum(row["seconds"] for row in prepared.values()), 2),
    },
    "human_perceptibility_confirmed": False,
    "first_time_duration_seconds": None,
    "independent_learning_observed": False,
}
(EVIDENCE / "comparison.json").write_text(json.dumps(comparison, indent=2) + "\n")
print("Compared L2/L3/L4 choices; independent pacing remains unmeasured.")
